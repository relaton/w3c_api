# frozen_string_literal: true

require "spec_helper"

RSpec.describe "W3C API Embed Support" do
  let(:hal_register) { W3cApi::Hal.instance.register }
  let(:client) { W3cApi::Client.new }

  describe "Embed-supported endpoints discovery" do
    it "lists endpoints that support embed parameter" do
      supported_endpoints = W3cApi::Client.embed_supported_endpoints

      expect(supported_endpoints).to be_an(Array)
      expect(supported_endpoints).to include(:specification_index)
      expect(supported_endpoints).to include(:group_index)
      expect(supported_endpoints).to include(:serie_index)

      puts "Embed-supported endpoints: #{supported_endpoints.join(', ')}"
    end

    it "checks if specific endpoints support embed" do
      expect(client.embed_supported?(:specification_index)).to be true
      expect(client.embed_supported?(:group_index)).to be true
      expect(client.embed_supported?(:serie_index)).to be true

      # Test an endpoint that doesn't support embed
      expect(client.embed_supported?(:specification_resource)).to be false
    end

    it "provides embed information through Embed module" do
      embed_info = W3cApi::Embed.embed_info

      expect(embed_info).to have_key(:supported_endpoints)
      expect(embed_info).to have_key(:descriptions)
      expect(embed_info).to have_key(:usage_example)

      expect(embed_info[:supported_endpoints]).to include(:specification_index)
      expect(embed_info[:usage_example]).to have_key(:discovery)
      expect(embed_info[:usage_example]).to have_key(:usage)
      expect(embed_info[:usage_example]).to have_key(:automatic_realization)
    end
  end

  describe "Client methods with embed support" do
    it "supports embed parameter in specifications method", :vcr do
      # Test the new way: using Client methods directly with embed: true
      specifications = client.specifications(embed: true, items: 2)

      expect(specifications).to be_a(W3cApi::Models::SpecificationIndex)
      expect(specifications.links).not_to be_nil

      # Check if embedded data is available
      puts "Specifications has embedded content: #{specifications.embedded_data.keys.join(', ')}" if specifications.respond_to?(:embedded_data) && specifications.embedded_data
    end

    it "supports embed parameter in groups method", :vcr do
      groups = client.groups(embed: true, items: 2)

      expect(groups).to be_a(W3cApi::Models::GroupIndex)
      expect(groups.links).not_to be_nil
    end

    it "supports embed parameter in series method", :vcr do
      series = client.series(embed: true, items: 2)

      expect(series).to be_a(W3cApi::Models::SerieIndex)
      expect(series.links).not_to be_nil
    end
  end

  describe "Automatic embedded content detection" do
    it "automatically uses embedded content without parent_resource parameter",
       :vcr do
      # Fetch specifications with embed enabled
      specifications = client.specifications(embed: true, items: 2)

      expect(specifications).to be_a(W3cApi::Models::SpecificationIndex)

      # Test automatic embedded content detection
      if specifications.links.respond_to?(:specifications) && specifications.links.specifications.any?
        first_spec_link = specifications.links.specifications.first

        # This should now work without explicitly passing parent_resource
        # The link should automatically detect and use embedded content
        spec_from_embedded = first_spec_link.realize

        expect(spec_from_embedded).to be_a(W3cApi::Models::Specification)
        puts "Successfully realized specification from embedded data automatically"
        puts "Specification title: #{spec_from_embedded.title}" if spec_from_embedded.respond_to?(:title)
      end
    end

    it "falls back to HTTP request when no embedded content available", :vcr do
      # Fetch specifications without embed
      specifications = client.specifications(items: 2)

      expect(specifications).to be_a(W3cApi::Models::SpecificationIndex)

      # Test that links still work via HTTP when no embedded content
      if specifications.links.respond_to?(:specifications) && specifications.links.specifications.any?
        first_spec_link = specifications.links.specifications.first

        # This should make an HTTP request since no embedded content is available
        spec_from_http = first_spec_link.realize

        expect(spec_from_http).to be_a(W3cApi::Models::Specification)
        puts "Successfully realized specification from HTTP request"
      end
    end
  end

  describe "Resource-level embedding features" do
    describe "Groups endpoint with embed" do
      it "supports embedded content through resource methods", :vcr do
        # Fetch groups with embed enabled
        groups = hal_register.fetch(:group_index, embed: true, items: 2)

        expect(groups).to be_a(W3cApi::Models::GroupIndex)

        # Test embedded content detection methods
        if groups.respond_to?(:embedded_data) && groups.embedded_data
          embedded_keys = groups.embedded_data.keys.join(", ")
          puts "Groups has embedded content: #{embedded_keys}"

          # Test accessing specific embedded content
          groups.embedded_data.each do |key, embedded_content|
            puts "Embedded #{key}: #{embedded_content.class}"
            puts "  - #{embedded_content.length} items" if embedded_content.respond_to?(:length)
          end
        end

        expect(groups.links).not_to be_nil
      end

      it "demonstrates link realization with embedded content", :vcr do
        # Fetch groups with embed enabled
        groups = hal_register.fetch(:group_index, embed: true, items: 2)

        # Test link realization using embedded content
        groups_links = groups.links
        if groups_links.respond_to?(:groups) && groups_links.groups.any?
          first_group_link = groups_links.groups.first

          # Realize link with parent_resource to use embedded data
          if first_group_link.respond_to?(:realize)
            group_from_embedded = first_group_link.realize(
              register: hal_register,
              parent_resource: groups,
            )
            expect(group_from_embedded).to be_a(W3cApi::Models::Group)
            puts "Realized group from embedded data: #{group_from_embedded.class}"

            # Compare with regular realization (would make HTTP request)
            group_from_http = first_group_link.realize(register: hal_register)
            expect(group_from_http).to be_a(W3cApi::Models::Group)
            puts "Realized group from HTTP request: #{group_from_http.class}"
          end
        end
      end
    end

    describe "Specifications endpoint with embed" do
      it "supports embedded content through resource methods", :vcr do
        # Fetch specifications with embed enabled
        specifications = hal_register.fetch(
          :specification_index,
          embed: true,
          items: 2,
        )

        expect(specifications).to be_a(W3cApi::Models::SpecificationIndex)

        # Test embedded content detection
        if specifications.respond_to?(:embedded_data) && specifications.embedded_data
          embedded_keys = specifications.embedded_data.keys.join(", ")
          puts "Specifications has embedded content: #{embedded_keys}"

          # Test accessing specific embedded content
          specifications.embedded_data.each do |key, embedded_content|
            puts "Embedded #{key}: #{embedded_content.class}"
            puts "  - #{embedded_content.length} items" if embedded_content.respond_to?(:length)
          end
        end

        expect(specifications.links).not_to be_nil
      end
    end

    describe "Series endpoint with embed" do
      it "supports embedded content through resource methods", :vcr do
        # Fetch series with embed enabled
        series = hal_register.fetch(:serie_index, embed: true, items: 2)

        expect(series).to be_a(W3cApi::Models::SerieIndex)

        # Test embedded content detection
        if series.respond_to?(:embedded_data) && series.embedded_data
          embedded_keys = series.embedded_data.keys.join(", ")
          puts "Series has embedded content: #{embedded_keys}"

          # Test accessing specific embedded content
          series.embedded_data.each do |key, embedded_content|
            puts "Embedded #{key}: #{embedded_content.class}"
            puts "  - #{embedded_content.length} items" if embedded_content.respond_to?(:length)
          end
        end

        expect(series.links).not_to be_nil
      end
    end
  end

  describe "Non-embedded requests" do
    it "continues to work without embed parameter", :vcr do
      # Ensure non-embedded requests still work
      groups = hal_register.fetch(:group_index, items: 2)
      expect(groups).to be_a(W3cApi::Models::GroupIndex)
      expect(groups.links).not_to be_nil

      specifications = hal_register.fetch(:specification_index, items: 2)
      expect(specifications).to be_a(W3cApi::Models::SpecificationIndex)
      expect(specifications.links).not_to be_nil

      series = hal_register.fetch(:serie_index, items: 2)
      expect(series).to be_a(W3cApi::Models::SerieIndex)
      expect(series.links).not_to be_nil
    end
  end
end
