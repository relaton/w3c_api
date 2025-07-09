#!/usr/bin/env ruby
# frozen_string_literal: true

require "stringio"
require_relative "../lib/w3c_api"

puts "=== W3C API Improved Embed Functionality Demo ==="
puts

# Test 1: List embed-supported endpoints
puts "1. Testing embed-supported endpoints discovery:"
supported_endpoints = W3cApi::Client.embed_supported_endpoints
puts "   Embed-supported endpoints: #{supported_endpoints.join(', ')}"
puts

# Test 2: Check specific endpoint support
puts "2. Testing specific endpoint embed support:"
client = W3cApi::Client.new
puts "   specifications supports embed: #{client.embed_supported?(:specification_index)}"
puts "   groups supports embed: #{client.embed_supported?(:group_index)}"
puts "   series supports embed: #{client.embed_supported?(:serie_index)}"
puts "   specification_resource supports embed: #{client.embed_supported?(:specification_resource)}"
puts

# Test 3: Get embed information
puts "3. Testing embed information:"
embed_info = W3cApi::Embed.embed_info
puts "   Supported endpoints: #{embed_info[:supported_endpoints].join(', ')}"
puts "   Discovery: #{embed_info[:usage_example][:discovery]}"
puts "   Usage: #{embed_info[:usage_example][:usage]}"
puts "   Automatic realization: #{embed_info[:usage_example][:automatic_realization]}"
puts

# Test 4: Use Client methods with embed
puts "4. Testing Client methods with embed parameter:"
begin
  puts "   Fetching specifications with embed=true..."
  specs = client.specifications(embed: true, items: 2)
  puts "   ✓ Successfully fetched #{specs.class}"

  if specs.respond_to?(:embedded_data) && specs.embedded_data
    puts "   ✓ Has embedded data: #{specs.embedded_data.keys.join(', ')}"
  else
    puts "   ⚠ No embedded data found"
  end

  # Test automatic embedded content detection
  if specs.links.respond_to?(:specifications) && specs.links.specifications.any?
    puts "   Testing automatic embedded content detection..."
    first_spec_link = specs.links.specifications.first

    begin
      # This should automatically use embedded content without parent_resource parameter
      spec = first_spec_link.realize
      puts "   ✓ Successfully realized specification automatically"
      puts "   ✓ Specification class: #{spec.class}"
      puts "   ✓ Specification title: #{spec.title}" if spec.respond_to?(:title)
    rescue StandardError => e
      puts "   ✗ Error realizing specification: #{e.message}"
    end
  end
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end
puts

# Test 5: Test Embed module information methods
puts "5. Testing Embed module information methods:"
begin
  puts "   Testing supported_endpoints method..."
  supported = W3cApi::Embed.supported_endpoints
  puts "   ✓ Supported endpoints: #{supported.join(', ')}"

  puts "   Testing supports_embed? method..."
  puts "   ✓ specifications supports embed: #{W3cApi::Embed.supports_embed?(:specification_index)}"
  puts "   ✓ groups supports embed: #{W3cApi::Embed.supports_embed?(:group_index)}"

  puts "   Testing endpoint_descriptions method..."
  descriptions = W3cApi::Embed.endpoint_descriptions
  puts "   ✓ Available descriptions: #{descriptions.keys.join(', ')}"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end
puts

puts "=== Demo completed ==="
puts "Summary of improvements:"
puts "• ✓ Added embed-supported endpoints discovery methods"
puts "• ✓ Client methods now support embed parameter directly"
puts "• ✓ Automatic embedded content detection (no parent_resource needed)"
puts "• ✓ Enhanced Embed module with information methods"
puts "• ✓ Removed deprecated code for cleaner API"
