# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::DelivererIndex do
  describe 'API integration', :vcr do
    let(:client) { W3cApi::Client.new }

    it 'fetches deliverers for a specification version' do
      VCR.use_cassette('specification_html5_version_20180327_deliverers') do
        version = client.specification_version('html5', '20180327')
        deliverers_index = version.links.deliverers.realize

        expect(deliverers_index).to be_a(described_class)
        expect(deliverers_index.links).to respond_to(:deliverers)
      end
    end

    it 'provides access to individual deliverers' do
      VCR.use_cassette('specification_html5_version_20180327_deliverers') do
        version = client.specification_version('html5', '20180327')
        deliverers_index = version.links.deliverers.realize

        deliverers = deliverers_index.links.deliverers
        expect(deliverers).to be_an(Array)
        expect(deliverers.length).to be > 0

        # Check that each deliverer is a Group object
        deliverers.each do |deliverer_link|
          deliverer = deliverer_link.realize
          expect(deliverer).to be_a(W3cApi::Models::Group)
          expect(deliverer).to respond_to(:name)
        end
      end
    end
  end

  describe 'collection behavior' do
    let(:deliverers_data) do
      {
        'page' => 1,
        'limit' => 100,
        'pages' => 1,
        'total' => 1,
        '_links' => {
          'deliverers' => [
            {
              'href' => 'https://api.w3.org/groups/wg/html',
              'title' => 'HTML Working Group'
            }
          ]
        }
      }
    end

    let(:deliverers_index) { described_class.from_json(deliverers_data.to_json) }

    it 'has deliverers collection' do
      expect(deliverers_index.links).to respond_to(:deliverers)
    end

    it 'provides access to deliverer links' do
      expect(deliverers_index.links.deliverers).to be_an(Array)
      expect(deliverers_index.links.deliverers.length).to eq(1)
    end

    it 'can realize individual deliverers' do
      deliverers_index.links.deliverers.each do |deliverer_link|
        expect(deliverer_link).to respond_to(:realize)
      end
    end
  end

  describe 'chained realization' do
    it 'allows chaining through multiple deliverer collections' do
      VCR.use_cassette('specification_html5_version_20180327_deliverers_chained') do
        client = W3cApi::Client.new
        version = client.specification_version('html5', '20180327')

        # Test that we can chain from version to deliverers to individual groups
        deliverers_index = version.links.deliverers.realize
        expect(deliverers_index).to be_a(described_class)

        if deliverers_index.links.deliverers.any?
          first_deliverer = deliverers_index.links.deliverers.first.realize
          expect(first_deliverer).to be_a(W3cApi::Models::Group)
        end
      end
    end
  end
end
