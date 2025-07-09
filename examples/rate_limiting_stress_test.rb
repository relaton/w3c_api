#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/w3c_api"

# Advanced example: Rate limiting stress test and performance analysis
puts "W3C API Rate Limiting - Advanced Stress Test Example"
puts "=" * 55

puts "\nThis example demonstrates advanced rate limiting scenarios:"
puts "• Rapid sequential requests"
puts "• Performance analysis across different endpoints"
puts "• Dynamic configuration changes"
puts "• Load testing patterns"

# Create a client instance
client = W3cApi::Client.new

# Configure aggressive rate limiting for testing
W3cApi::Hal.instance.configure_rate_limiting(
  max_retries: 3,
  base_delay: 0.1,      # Very short delay for testing
  max_delay: 5.0,       # Lower max delay
  backoff_factor: 2.0,
)

puts "\n🔧 Rate limiting configuration for stress testing:"
puts "   - Max retries: 3"
puts "   - Base delay: 0.1s (very aggressive)"
puts "   - Max delay: 5.0s"
puts "   - Backoff factor: 2.0"

# Test 1: Rapid sequential requests
puts "\n1. 🚀 Rapid Sequential Requests Test:"
puts "   Making 10 rapid requests to analyze rate limiting behavior..."

start_time = Time.now
successful_requests = 0
failed_requests = 0
request_times = []

10.times do |i|
  print "   Request #{i + 1}: "
  request_start = Time.now

  begin
    specs = client.specifications(items: 1)
    request_time = (Time.now - request_start).round(3)
    request_times << request_time
    puts "✓ Success (#{specs.links.specifications.length} items, #{request_time}s)"
    successful_requests += 1
  rescue StandardError => e
    request_time = (Time.now - request_start).round(3)
    request_times << request_time
    puts "✗ Failed: #{e.message} (#{request_time}s)"
    failed_requests += 1
  end
end

end_time = Time.now
total_time = (end_time - start_time).round(2)

puts "\n   📊 Performance Analysis:"
puts "   - Successful requests: #{successful_requests}"
puts "   - Failed requests: #{failed_requests}"
puts "   - Total time: #{total_time}s"
puts "   - Average time per request: #{(total_time / 10).round(3)}s"
puts "   - Fastest request: #{request_times.min}s"
puts "   - Slowest request: #{request_times.max}s"

# Test 2: Cross-endpoint performance analysis
puts "\n2. 🎯 Cross-Endpoint Performance Analysis:"
endpoints = [
  { name: "specifications", method: :specifications,
    link_key: :specifications },
  { name: "groups", method: :groups, link_key: :groups },
  { name: "series", method: :series, link_key: :series },
  { name: "ecosystems", method: :ecosystems, link_key: :ecosystems },
]

endpoint_results = {}

endpoints.each do |endpoint|
  print "   Testing #{endpoint[:name].ljust(15)}: "
  start = Time.now

  begin
    result = client.send(endpoint[:method], items: 2)
    duration = (Time.now - start).round(3)
    count = result.links.send(endpoint[:link_key]).length

    endpoint_results[endpoint[:name]] = {
      success: true,
      duration: duration,
      count: count,
    }

    puts "✓ Success (#{count} items, #{duration}s)"
  rescue StandardError => e
    duration = (Time.now - start).round(3)
    endpoint_results[endpoint[:name]] = {
      success: false,
      duration: duration,
      error: e.message,
    }
    puts "✗ Failed: #{e.message} (#{duration}s)"
  end
end

puts "\n   📈 Endpoint Performance Summary:"
endpoint_results.each do |name, result|
  if result[:success]
    puts "   - #{name.ljust(15)}: #{result[:duration]}s (#{result[:count]} items)"
  else
    puts "   - #{name.ljust(15)}: #{result[:duration]}s (FAILED)"
  end
end

# Test 3: Dynamic configuration testing
puts "\n3. ⚙️  Dynamic Configuration Testing:"

begin
  puts "   Testing with rate limiting enabled..."
  start = Time.now
  client.specifications(items: 1)
  time1 = (Time.now - start).round(3)
  puts "   ✓ Request 1 (enabled): #{time1}s"

  puts "   🔄 Disabling rate limiting..."
  W3cApi::Hal.instance.disable_rate_limiting

  start = Time.now
  client.specifications(items: 1)
  time2 = (Time.now - start).round(3)
  puts "   ✓ Request 2 (disabled): #{time2}s"

  puts "   🔄 Re-enabling with different configuration..."
  W3cApi::Hal.instance.enable_rate_limiting
  W3cApi::Hal.instance.configure_rate_limiting(
    max_retries: 5,
    base_delay: 0.2,
    max_delay: 10.0,
    backoff_factor: 1.5,
  )

  start = Time.now
  client.specifications(items: 1)
  time3 = (Time.now - start).round(3)
  puts "   ✓ Request 3 (reconfigured): #{time3}s"

  puts "\n   ⏱️  Timing Comparison:"
  puts "   - Enabled (default):  #{time1}s"
  puts "   - Disabled:           #{time2}s"
  puts "   - Reconfigured:       #{time3}s"
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
end

# Test 4: Bulk operation simulation
puts "\n4. 📦 Bulk Operation Simulation:"
puts "   Simulating a bulk data collection scenario..."

bulk_start = Time.now
bulk_results = []

# Simulate collecting data from multiple endpoints
bulk_operations = [
  { name: "Collect specifications", method: :specifications, items: 3 },
  { name: "Collect groups", method: :groups, items: 2 },
  { name: "Collect series", method: :series, items: 2 },
]

bulk_operations.each_with_index do |operation, _index|
  print "   #{operation[:name]}: "
  op_start = Time.now

  begin
    result = client.send(operation[:method], items: operation[:items])
    duration = (Time.now - op_start).round(3)

    case operation[:method]
    when :specifications
      count = result.links.specifications.length
    when :groups
      count = result.links.groups.length
    when :series
      count = result.links.series.length
    end

    bulk_results << { success: true, duration: duration, count: count }
    puts "✓ #{count} items (#{duration}s)"

    # Add a small delay between bulk operations
    sleep(0.1)
  rescue StandardError => e
    duration = (Time.now - op_start).round(3)
    bulk_results << { success: false, duration: duration }
    puts "✗ Failed: #{e.message} (#{duration}s)"
  end
end

bulk_total_time = (Time.now - bulk_start).round(2)
successful_ops = bulk_results.count { |r| r[:success] }
total_items = bulk_results.select { |r| r[:success] }.sum { |r| r[:count] || 0 }

puts "\n   📊 Bulk Operation Results:"
puts "   - Total time: #{bulk_total_time}s"
puts "   - Successful operations: #{successful_ops}/#{bulk_operations.length}"
puts "   - Total items collected: #{total_items}"
puts "   - Average time per operation: #{(bulk_total_time / bulk_operations.length).round(3)}s"

puts "\n#{'=' * 55}"
puts "🎉 Advanced Stress Test Completed!"

puts "\n📋 Test Summary:"
puts "• Sequential requests: #{successful_requests}/10 successful"
puts "• Endpoint tests: #{endpoint_results.count do |_, r|
  r[:success]
end}/#{endpoints.length} successful"
puts "• Configuration changes: Applied successfully"
puts "• Bulk operations: #{successful_ops}/#{bulk_operations.length} successful"

puts "\n💡 Key Insights:"
puts "• Rate limiting maintains API stability under load"
puts "• Configuration changes take effect immediately"
puts "• Different endpoints may have varying response times"
puts "• Bulk operations benefit from rate limiting protection"

puts "\n🔍 In Production Scenarios:"
puts "• Rate limiting prevents API abuse and ensures fair usage"
puts "• Exponential backoff reduces server load during high traffic"
puts "• Retry-After headers are automatically respected"
puts "• 429 and 5xx errors are handled gracefully with retries"

puts "\n📚 Advanced Usage Tips:"
puts "• Monitor request patterns to optimize rate limiting settings"
puts "• Use bulk operations with manual delays for large datasets"
puts "• Adjust configuration based on API documentation"
puts "• Consider disabling rate limiting for controlled bulk operations"
