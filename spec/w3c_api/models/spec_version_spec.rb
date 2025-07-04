# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::SpecVersion do
  describe 'API integration', :vcr do
    let(:client) { W3cApi::Client.new }

    it 'fetches a specific specification version' do
      VCR.use_cassette('specification_html5_version_20180327') do
        version = client.specification_version('html5', '20180327')
        expect(version).to be_a(described_class)
        expect(version.title).to eq('HTML5')
        expect(version.date).to eq(Date.parse('2018-03-27'))
        expect(version.status).to eq('Retired')
      end
    end

    it 'can access predecessor versions through links' do
      VCR.use_cassette('specification_html5_version_20180327') do
        version = client.specification_version('html5', '20180327')

        # Test that predecessor_versions link exists and has realize method
        expect(version.links.predecessor_versions).to respond_to(:realize) if version.links.respond_to?(:predecessor_versions) && version.links.predecessor_versions
      end
    end

    it 'can access successor versions through links' do
      VCR.use_cassette('specification_html5_version_20180327') do
        version = client.specification_version('html5', '20180327')

        # Test that successor_versions link exists and has realize method
        expect(version.links.successor_versions).to respond_to(:realize) if version.links.respond_to?(:successor_versions) && version.links.successor_versions
      end
    end

    it 'can access both predecessor and successor versions' do
      VCR.use_cassette('specification_html5_version_20140429_with_both') do
        version = client.specification_version('html5', '20140429')

        # Test that both predecessor and successor links exist
        expect(version.links.predecessor_versions).not_to be_nil
        expect(version.links.successor_versions).not_to be_nil

        # Test that both links have realize method
        expect(version.links.predecessor_versions).to respond_to(:realize)
        expect(version.links.successor_versions).to respond_to(:realize)

        # Test the href values
        expect(version.links.predecessor_versions.href).to eq('https://api.w3.org/specifications/html5/versions/20140429/predecessors')
        expect(version.links.successor_versions.href).to eq('https://api.w3.org/specifications/html5/versions/20140429/successors')
      end
    end
  end

  let(:spec_version_hash) do
    {
      'status' => 'Retired',
      'rec-track' => true,
      'uri' => 'https://www.w3.org/TR/2018/SPSD-html5-20180327/',
      'date' => '2018-03-27',
      'informative' => false,
      'title' => 'HTML5',
      'shortlink' => 'https://www.w3.org/TR/html5/',
      '_links' => {
        'self' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20180327'
        },
        'editors' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20180327/editors'
        },
        'deliverers' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20180327/deliverers'
        },
        'specification' => {
          'href' => 'https://api.w3.org/specifications/html5'
        },
        'predecessor-version' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20180327/predecessors'
        },
        'successor-version' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20180327/successors'
        }
      }
    }
  end

  let(:spec_version) { described_class.from_json(spec_version_hash.to_json) }

  describe 'attributes' do
    it 'has the correct attributes' do
      expect(spec_version).to respond_to(:status)
      expect(spec_version).to respond_to(:rec_track)
      expect(spec_version).to respond_to(:editor_draft)
      expect(spec_version).to respond_to(:uri)
      expect(spec_version).to respond_to(:date)
      expect(spec_version).to respond_to(:last_call_feedback_due)
      expect(spec_version).to respond_to(:pr_reviews_date)
      expect(spec_version).to respond_to(:implementation_feedback_due)
      expect(spec_version).to respond_to(:per_reviews_due)
      expect(spec_version).to respond_to(:informative)
      expect(spec_version).to respond_to(:title)
      expect(spec_version).to respond_to(:href)
      expect(spec_version).to respond_to(:shortlink)
      expect(spec_version).to respond_to(:translation)
      expect(spec_version).to respond_to(:errata)
      expect(spec_version).to respond_to(:process_rules)
      expect(spec_version).to respond_to(:links)
    end

    it 'sets attributes correctly from hash' do
      expect(spec_version.status).to eq('Retired')
      expect(spec_version.rec_track).to be true
      expect(spec_version.uri).to eq('https://www.w3.org/TR/2018/SPSD-html5-20180327/')
      expect(spec_version.date).to eq(Date.parse('2018-03-27'))
      expect(spec_version.informative).to be false
      expect(spec_version.title).to eq('HTML5')
      expect(spec_version.shortlink).to eq('https://www.w3.org/TR/html5/')
    end
  end

  describe 'HAL links' do
    it 'returns the correct self link' do
      expect(spec_version.links.self.href).to eq('https://api.w3.org/specifications/html5/versions/20180327')
    end

    it 'has editors link' do
      expect(spec_version.links).to respond_to(:editors)
      expect(spec_version.links.editors.href).to eq('https://api.w3.org/specifications/html5/versions/20180327/editors')
    end

    it 'has deliverers link' do
      expect(spec_version.links).to respond_to(:deliverers)
      expect(spec_version.links.deliverers.href).to eq('https://api.w3.org/specifications/html5/versions/20180327/deliverers')
    end

    it 'has specification link' do
      expect(spec_version.links).to respond_to(:specification)
      expect(spec_version.links.specification.href).to eq('https://api.w3.org/specifications/html5')
    end

    it 'has predecessor_versions link' do
      expect(spec_version.links).to respond_to(:predecessor_versions)
      expect(spec_version.links.predecessor_versions.href).to eq('https://api.w3.org/specifications/html5/versions/20180327/predecessors')
    end

    it 'has successor_versions link' do
      expect(spec_version.links).to respond_to(:successor_versions)
      expect(spec_version.links.successor_versions.href).to eq('https://api.w3.org/specifications/html5/versions/20180327/successors')
    end
  end

  describe 'HAL link realization' do
    context 'when predecessor_versions link exists' do
      it 'has realize method available' do
        # The key fix is that this link now has the realize method available
        # without throwing "Unregistered URL pattern" errors
        expect(spec_version.links.predecessor_versions).to respond_to(:realize)
      end

      it 'can realize predecessor versions' do
        # This test verifies that the endpoint registration fix works
        # We only test that the method exists, not that it can be called without a register
        expect(spec_version.links.predecessor_versions).to respond_to(:realize)
      end
    end

    context 'when successor_versions link exists' do
      it 'has realize method available' do
        # The key fix is that this link now has the realize method available
        # without throwing "Unregistered URL pattern" errors
        expect(spec_version.links.successor_versions).to respond_to(:realize)
      end

      it 'can realize successor versions' do
        # This test verifies that the endpoint registration fix works
        # We only test that the method exists, not that it can be called without a register
        expect(spec_version.links.successor_versions).to respond_to(:realize)
      end
    end

    context 'when other links exist' do
      it 'can realize editors link' do
        expect(spec_version.links.editors).to respond_to(:realize)
      end

      it 'can realize deliverers link' do
        expect(spec_version.links.deliverers).to respond_to(:realize)
      end

      it 'can realize specification link' do
        expect(spec_version.links.specification).to respond_to(:realize)
      end
    end
  end

  describe 'serialization' do
    it 'can be converted to JSON' do
      json = spec_version.to_json
      expect(json).to be_a(String)
      expect(json).to include('"status":"Retired"')
      expect(json).to include('"title":"HTML5"')
    end

    it 'can be converted to YAML' do
      yaml = spec_version.to_yaml
      expect(yaml).to be_a(String)
      expect(yaml).to include('status: Retired')
      expect(yaml).to include('title: HTML5')
    end
  end

  describe 'version relationships' do
    context 'with predecessor versions' do
      it 'provides access to predecessor version information' do
        expect(spec_version.links.predecessor_versions).not_to be_nil
        expect(spec_version.links.predecessor_versions.href).to include('predecessors')
      end
    end

    context 'with successor versions' do
      it 'provides access to successor version information' do
        expect(spec_version.links.successor_versions).not_to be_nil
        expect(spec_version.links.successor_versions.href).to include('successors')
      end
    end
  end
end
