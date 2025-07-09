#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "lib/w3c_api"

def test_link_realization(groups_with_embed)
  return unless groups_with_embed.respond_to?(:links) && groups_with_embed.links.respond_to?(:groups)

  first_group_link = groups_with_embed.links.groups.first
  return unless first_group_link

  puts "   First group link: #{first_group_link.href}"
  return unless first_group_link.respond_to?(:realize)

  begin
    realized_group = first_group_link.realize(parent_resource: groups_with_embed)
    puts "   ✓ Link realization with embedded data successful"
    puts "   Realized group name: #{realized_group.name if realized_group.respond_to?(:name)}"
  rescue StandardError => e
    puts "   ⚠ Link realization failed: #{e.message}"
  end
end

puts "Testing W3C API Embed Functionality"
puts "=" * 40

# Initialize the client
client = W3cApi::Client.new

begin
  puts "\n1. Testing Groups endpoint with embed..."
  groups_with_embed = client.groups(embed: true, items: 5)

  puts "   Response type: #{groups_with_embed.class}"
  puts "   Has embedded content: #{groups_with_embed.respond_to?(:has_embedded?) && groups_with_embed.has_embedded?('groups')}"

  if groups_with_embed.respond_to?(:has_embedded?) && groups_with_embed.has_embedded?("groups")
    puts "   Available methods: #{groups_with_embed.methods.grep(/embed/).join(', ')}"

    embedded_groups = groups_with_embed.get_embedded("groups")
    puts "   Number of embedded groups: #{embedded_groups.length}"
    puts "   First embedded group: #{embedded_groups.first['name'] if embedded_groups.first}"
  end

  puts "\n2. Testing Specifications endpoint with embed..."
  specs_with_embed = client.specifications(embed: true, items: 5)

  puts "   Response type: #{specs_with_embed.class}"
  puts "   Has embedded content: #{specs_with_embed.respond_to?(:has_embedded?) && specs_with_embed.has_embedded?('specifications')}"

  if specs_with_embed.respond_to?(:has_embedded?) && specs_with_embed.has_embedded?("specifications")
    puts "   Available methods: #{specs_with_embed.methods.grep(/embed/).join(', ')}"

    embedded_specs = specs_with_embed.get_embedded("specifications")
    puts "   Number of embedded specifications: #{embedded_specs.length}"
    puts "   First embedded spec: #{embedded_specs.first['title'] if embedded_specs.first}"
  end

  puts "\n3. Testing comparison: with vs without embed..."

  # Without embed
  start_time = Time.now
  client.groups(items: 3)
  without_embed_time = Time.now - start_time
  puts "   Without embed: #{without_embed_time.round(3)}s"

  # With embed
  start_time = Time.now
  groups_with_embed = client.groups(embed: true, items: 3)
  with_embed_time = Time.now - start_time
  puts "   With embed: #{with_embed_time.round(3)}s"

  if groups_with_embed.respond_to?(:has_embedded?) && groups_with_embed.has_embedded?("groups")
    puts "   ✓ Embed functionality working correctly!"
  else
    puts "   ⚠ Embed parameter accepted but no embedded content returned"
  end

  puts "\n4. Testing link realization with embedded content..."
  test_link_realization(groups_with_embed)

  puts "\n✅ Embed functionality test completed successfully!"
rescue StandardError => e
  puts "\n❌ Error during testing: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(5).join("\n")
end
