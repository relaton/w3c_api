#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/w3c_api"

# Demo script to demonstrate rate limiting functionality
puts "W3C API Rate Limiting Demo"
puts "=" * 40

puts "\nThis demo shows how to use the built-in rate limiting features"
puts "of the W3C API client to handle API rate limits gracefully."

# Create a client instance
client = W3cApi::Client.new

# Demo 1: Default rate limiting (enabled by default)
puts "\n1. Default Rate Limiting Configuration:"
puts "   - Max retries: 3"
puts "   - Base delay: 1.0s"
puts "   - Max delay: 60.0s"
puts "   - Backoff factor: 2.0"

begin
  start_time = Time.now

  puts "\n   Making API requests with default rate limiting..."

  # Fetch specifications
  specs = client.specifications(items: 3)
  puts "   ✓ Retrieved #{specs.links.specifications.length} specifications"

  # Fetch a specific specification
  spec_detail = client.specification("html5")
  puts "   ✓ Retrieved specification: #{spec_detail.title}"

  end_time = Time.now
  puts "   ⏱️  Total time: #{(end_time - start_time).round(2)}s"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Demo 2: Custom rate limiting configuration
puts "\n2. Custom Rate Limiting Configuration:"
puts "   Configuring more aggressive rate limiting for APIs with strict limits"

begin
  # Configure custom rate limiting
  W3cApi::Hal.instance.configure_rate_limiting(
    max_retries: 5,        # More retry attempts
    base_delay: 0.5,       # Shorter initial delay
    max_delay: 30.0,       # Lower maximum delay
    backoff_factor: 1.5, # Gentler backoff
  )

  puts "   ✓ Rate limiting reconfigured"

  start_time = Time.now

  # Make requests with custom configuration
  groups = client.groups(items: 3)
  puts "   ✓ Retrieved #{groups.links.groups.length} groups"

  end_time = Time.now
  puts "   ⏱️  Total time: #{(end_time - start_time).round(2)}s"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Demo 3: Temporarily disable rate limiting
puts "\n3. Temporarily Disabling Rate Limiting:"
puts "   Useful for bulk operations where you control the rate manually"

begin
  # Disable rate limiting
  W3cApi::Hal.instance.disable_rate_limiting
  puts "   ✓ Rate limiting disabled"

  start_time = Time.now

  # Make requests without rate limiting
  series = client.series(items: 3)
  puts "   ✓ Retrieved #{series.links.series.length} series"

  end_time = Time.now
  puts "   ⏱️  Total time: #{(end_time - start_time).round(2)}s"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Demo 4: Re-enable rate limiting
puts "\n4. Re-enabling Rate Limiting:"

begin
  # Re-enable rate limiting with default settings
  W3cApi::Hal.instance.enable_rate_limiting
  puts "   ✓ Rate limiting re-enabled with default settings"

  start_time = Time.now

  ecosystems = client.ecosystems
  puts "   ✓ Retrieved #{ecosystems.links.ecosystems.length} ecosystems"

  end_time = Time.now
  puts "   ⏱️  Total time: #{(end_time - start_time).round(2)}s"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Demo 5: Check rate limiting status
puts "\n5. Checking Rate Limiting Status:"

if W3cApi::Hal.instance.rate_limiting_enabled?
  puts "   ✓ Rate limiting is currently ENABLED"
else
  puts "   ⚠️  Rate limiting is currently DISABLED"
end

puts "\n#{'=' * 40}"
puts "Rate Limiting Demo Completed! 🎉"

puts "\n📚 Key Takeaways:"
puts "• Rate limiting is enabled by default for reliable API access"
puts "• You can customize retry behavior for different API requirements"
puts "• Rate limiting can be temporarily disabled for bulk operations"
puts "• The system automatically handles 429 and 5xx errors with exponential backoff"
puts "• Retry-After headers from the server are automatically respected"

puts "\n🔧 Common Use Cases:"
puts "• Default settings work well for most applications"
puts "• Increase max_retries for critical operations"
puts "• Decrease delays for APIs with generous rate limits"
puts "• Disable temporarily for bulk data processing"

puts "\n📖 For more information, see the rate limiting documentation"
puts "   in the lutaml-hal library or the W3C API documentation."
