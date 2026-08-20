# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`w3c_api` is a Ruby client + Thor CLI for the W3C API (https://api.w3.org).
It is a thin layer over [lutaml-hal](https://github.com/lutaml/lutaml-hal):
lutaml-hal owns the HTTP client, HAL link realization, and pagination; this gem
contributes the endpoint registry, the resource models, a convenience `Client`
facade, and the CLI.

## Commands

```sh
bundle install              # install dependencies
bundle exec rake            # default task: spec + rubocop
bundle exec rake spec       # run all tests
bundle exec rake rubocop    # lint only
bundle exec rspec spec/w3c_api/client_spec.rb          # single file
bundle exec rspec spec/w3c_api/client_spec.rb:42       # single example by line
exe/w3c_api <command>       # run the CLI without installing
```

Note: the README's `bin/setup` and `bin/console` do not exist in this repo —
use `bundle install` and `bundle exec`.

## Architecture

The request path is: **CLI command → `Client` → `Hal` register → lutaml-hal →
`Models`**.

- **`lib/w3c_api/hal.rb`** — the heart of the gem. `Hal` is a `Singleton` that
  builds the Faraday connection (with retry + cache config) and registers
  *every* API endpoint in `setup`
  (one `add_endpoint` call per endpoint, mapping an endpoint id like
  `:specification_resource` → URL template + model + parameters). To add or
  change an API endpoint, edit `setup` here. `SimpleParameter` exists only to
  satisfy lutaml-hal's parameter-validation interface without pulling in its
  full `EndpointParameter` machinery.

- **`lib/w3c_api/client.rb`** — `Client` is a flat convenience facade. Almost
  every method is one line delegating to `Hal.instance.register.fetch(endpoint_id, **params)`
  via the private `fetch_resource`. Many method families
  (`group_*`, `user_*`, `affiliation_*`, `ecosystem_*`) are generated with
  `define_method` loops — follow that pattern rather than writing them out.

- **`lib/w3c_api/models/`** — one file per resource. Two kinds:
  - **Resources** subclass `Lutaml::Hal::Resource` (e.g. `Specification`).
  - **Indexes** subclass `Lutaml::Hal::Page` (e.g. `SpecificationIndex`) and
    provide pagination.
  Models declare attributes, `hal_link` relationships (each link names a
  `realize_class` and may be a `collection`), and a `key_value` block mapping
  the API's hyphenated JSON keys (`series-version`) to underscored Ruby
  attributes (`series_version`). `models.rb` requires every model file.

- **`lib/w3c_api/commands/`** — one Thor class per resource, all wired into the
  root `Cli` in `cli.rb` as subcommands. Commands instantiate `Client`, call
  it, and print via the shared `OutputFormatter` (`--format yaml|json`, YAML
  default). `exe/w3c_api` is the executable.

### HAL link realization

The defining feature: links are lazy. Calling `.realize` on a link follows its
`href` and returns the typed model — and chains
(`spec.links.latest_version.realize.links.editors...`). With `embed: true` on
supported index endpoints (`:specification_index`, `:group_index`,
`:serie_index`), the index response embeds child resources and `.realize` uses
that embedded data instead of issuing a new HTTP request (see
`lib/w3c_api/embed.rb` and `Client.embed_supported_endpoints`).

### Rate limiting & retries (`hal.rb`)

Two cooperating layers, both tuned to grow 1→2→4→8→16s:
- lutaml-hal's `RateLimiter` (via `rate_limiting_options`) retries **429 and
  5xx**.
- A Faraday `:retry` middleware in `connection` (`DEFAULT_RETRY_OPTIONS`) covers
  what lutaml-hal does not: the W3C API signals rate-limiting with **HTTP 403**,
  plus connection/timeout errors.

Two footguns in the Faraday layer, both encoded in constants in `hal.rb` — do
not "tidy" them away (see issue #23):
- `exceptions:` **replaces** faraday-retry's `DEFAULT_EXCEPTIONS`, it does not
  merge. `retry_statuses: [403]` is implemented by raising
  `Faraday::RetriableResponse` internally and rescuing it via `exceptions:`, so
  dropping that class disables 403 retries *and* leaks the raise to the caller
  on the first 403. Hence `RETRY_EXCEPTIONS` is built on top of the defaults.
- `max_interval` caps `Retry-After` as well as the computed backoff, and a
  `Retry-After` above it makes faraday-retry stop retrying entirely rather than
  wait longer. Hence 60s, well above the largest computed backoff (16s).

Owning retries in the client means consumers get resilience without wrapping.
Tune via `Hal.instance.configure_rate_limiting(...)` and
`Hal.instance.configure_retry(...)` — both go through the memoization cascade
below. There is no `disable_retry`; `configure_retry(max: 0)` is the off switch.

Once retries are exhausted a 403 surfaces as `Lutaml::Hal::Error` (its
`handle_response` has no 403 branch, so 403 falls through to the generic
`raise Error`), not as a `Faraday::RetriableResponse`.

### User agent (`hal.rb`)

Requests carry `w3c_api/<VERSION> (+<repo url>)` (`DEFAULT_USER_AGENT`) — a bare
Faraday user agent is a prime trigger for the Cloudflare bot heuristics in front
of `api.w3.org`, and W3C asks consumers to identify themselves. Override with
`Hal.instance.configure_user_agent(...)` (wins), the `W3C_API_USER_AGENT`
environment variable, or the CLI's `--user-agent` flag. The flag comes from
`Commands::UserAgentOption`, mixed into every command class — Thor cannot parse
options placed before a subcommand name, so it cannot live on the root `Cli`.

Note that per-request `headers:` passed to `Client` methods never reach the wire:
lutaml-hal only forwards headers declared as endpoint parameters with
`location: :header`, and `SimpleParameter` only produces `:path`/`:query`. The
connection-level user agent is the working mechanism.

### Memoization cascade (`hal.rb`)

Memoization runs `@register → @client → @connection`, and `ModelRegister` keeps
the client it was built with — so any connection- or client-level change must
rebuild all three. Every `configure_*` setter funnels through
`reset_connection → reset_client → rebuild_register` accordingly.

`rebuild_register` rebuilds **eagerly**, and that is load-bearing: `Link#realize`
resolves the register via `GlobalRegister.instance.get(:w3c_api)`, which *raises*
when the name is absent. A lazy `reset_register` would leave every
already-fetched model unable to realize its links until something re-entered
`Hal#register`. The trade-off is that each `configure_*` call starts a fresh
object cache — they are start-up knobs, not mid-crawl ones.

### Caching (`hal.rb`)

lutaml-hal caches realized objects keyed by their canonical URL, so a document
linked from many places (editors, working groups, versions) is fetched once per
process. It is **enabled by default** (in-memory) — the register is built with
`cache: cache_options`. Tune or persist via `Hal.instance.configure_cache(...)`
(e.g. a `:filesystem` adapter) or turn it off with `disable_cache`; like the
rate-limiting setters these rebuild the register. `reset_register` also
unregisters from lutaml-hal's `GlobalRegister`, otherwise the rebuild raises
"replacing another one".

## Testing

Specs use **VCR** (`hook_into :faraday`) with cassettes in
`spec/fixtures/vcr_cassettes/`. Default record mode is `:new_episodes` and
requests match on `method, uri, body` — so a new test that hits an unrecorded
request will perform a real HTTP call and record it (pass `record: :none` to a
cassette to make a mismatch raise instead). `spec_helper.rb` calls
`configure_user_agent(nil)` before every example, which cascades through the
whole memoization chain — connection, client, register — and unregisters from
the lutaml-hal `GlobalRegister` to prevent cross-test endpoint-registration
bleed. That also gives each example a fresh object cache, so caching doesn't
mask expected requests.

`spec/w3c_api/hal_spec.rb` is the one spec that opts out of VCR: it drives a
`Faraday::Adapter::Test` connection and wraps every example in
`VCR.turned_off`, because the `:faraday` hook injects VCR into *that*
connection too and would otherwise reject the request as unhandled. It also
restores `@retry_options` in an `around` hook: the per-example
`configure_user_agent(nil)` rebuilds connection, client and register, but
nothing resets the retry options, so a `configure_retry` call would otherwise
persist for the whole suite process.

## Conventions

- Ruby >= 3.1. RuboCop inherits Ribose's shared OSS config; `LineLength` max is
  180. `.rubocop_todo.yml` holds grandfathered offences — prefer fixing over
  growing it.
- Endpoint ids follow `<resource>_resource` (single) / `<resource>_index`
  (collection) naming; keep new ids consistent so the `define_method` loops and
  `embed_supported?` discovery keep working.
