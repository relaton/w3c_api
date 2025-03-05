# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3c::Api::Models::Series do
  let(:series_hash) do
    {
      'shortname' => 'webrtc',
      'name' => 'WebRTC: Real-Time Communication Between Browsers',
      '_links' => {
        'self' => {
          'href' => 'https://api.w3.org/specification-series/webrtc'
        },
        'specifications' => {
          'href' => 'https://api.w3.org/specification-series/webrtc/specifications'
        },
        'current-specification' => {
          'href' => 'https://api.w3.org/specifications/webrtc'
        }
      }
    }
  end

  let(:series) { described_class.from_response(series_hash) }

  describe 'attributes' do
    it 'has the correct attributes' do
      expect(series).to respond_to(:shortname)
      expect(series).to respond_to(:name)
      expect(series).to respond_to(:_links)
    end

    it 'sets attributes correctly from hash' do
      expect(series.shortname).to eq('webrtc')
      expect(series.name).to eq('WebRTC: Real-Time Communication Between Browsers')
    end
  end

  describe 'helper methods' do
    it 'returns the correct links' do
      expect(series._links.self.href).to eq('https://api.w3.org/specification-series/webrtc')
      expect(series._links.specifications.href).to eq('https://api.w3.org/specification-series/webrtc/specifications')
      expect(series._links.current_specification.href).to eq('https://api.w3.org/specifications/webrtc')
    end
  end

  describe 'specifications' do
    let(:client) { instance_double(W3c::Api::Client) }
    let(:specifications) { [instance_double(W3c::Api::Models::Specification)] }

    it 'fetches specifications using the client' do
      expect(client).to receive(:series_specifications).with('webrtc').and_return(specifications)
      expect(series.specifications(client)).to eq(specifications)
    end
  end

  describe 'current_specification' do
    let(:client) { instance_double(W3c::Api::Client) }
    let(:specification) { instance_double(W3c::Api::Models::Specification) }

    it 'fetches current specification using the client' do
      expect(client).to receive(:specification).with('webrtc').and_return(specification)
      expect(series.current_specification(client)).to eq(specification)
    end
  end

  describe 'serialization' do
    it 'can be converted to XML and YAML' do
      expect { series.to_xml }.not_to raise_error
      expect { series.to_yaml }.not_to raise_error
    end
  end
end
