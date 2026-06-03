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
- A Faraday `:retry` middleware in `connection` covers what lutaml-hal does not:
  the W3C API signals rate-limiting with **HTTP 403**, plus connection/timeout
  errors.

Owning retries in the client means consumers get resilience without wrapping.
Tune via `Hal.instance.configure_rate_limiting(...)`; changing options resets
the memoized client.

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
request will perform a real HTTP call and record it. `spec_helper.rb` resets the
`Hal` singleton's register and the lutaml-hal `GlobalRegister` around every
example to prevent cross-test endpoint-registration bleed — which also gives
each example a fresh object cache, so caching doesn't mask expected requests.

## Conventions

- Ruby >= 3.1. RuboCop inherits Ribose's shared OSS config; `LineLength` max is
  180. `.rubocop_todo.yml` holds grandfathered offences — prefer fixing over
  growing it.
- Endpoint ids follow `<resource>_resource` (single) / `<resource>_index`
  (collection) naming; keep new ids consistent so the `define_method` loops and
  `embed_supported?` discovery keep working.
