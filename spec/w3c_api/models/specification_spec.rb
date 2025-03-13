# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::Specification do
  describe 'API integration', :vcr do
    let(:client) { W3cApi::Client.new }

    it 'fetches HTML5 specification' do
      VCR.use_cassette('model_specification_html5') do
        specification = client.specification('html5')
        expect(specification).to be_a(described_class)
        expect(specification.shortname).to eq('html5')
        expect(specification.title).to eq('HTML5')
        expect(specification.links.self.href).to include('html5')
      end
    end

    it 'fetches versions of a specification' do
      VCR.use_cassette('model_specification_html5_versions') do
        specification = client.specification('html5')
        versions = specification.links.version_history
        expect(versions.class.name).to be_eql('W3cApi::Models::SpecVersionIndexLink')
        expect(versions.href).to be_eql('https://api.w3.org/specifications/html5/versions')
      end
    end
  end
  let(:spec_hash) do
    {
      'shortlink' => 'https://www.w3.org/TR/html5/',
      'description' => '<p>This specification defines the 5th major revision of the core language of the World Wide Web: the Hypertext Markup Language (HTML).</p>',
      'title' => 'HTML 5.3',
      'shortname' => 'html5',
      'editor-draft' => 'https://w3c.github.io/html/',
      'series-version' => '5.3',
      '_links' => {
        'self' => {
          'href' => 'https://api.w3.org/specifications/html5'
        },
        'version-history' => {
          'href' => 'https://api.w3.org/specifications/html5/versions'
        },
        'first-version' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20080122',
          'title' => 'Working Draft'
        },
        'latest-version' => {
          'href' => 'https://api.w3.org/specifications/html5/versions/20171214',
          'title' => 'REC'
        },
        'supersedes' => {
          'href' => 'https://api.w3.org/specifications/html5/supersedes'
        },
        'series' => {
          'href' => 'https://api.w3.org/specification-series/html'
        }
      }
    }
  end

  let(:specification) { described_class.from_json(spec_hash.to_json) }

  describe 'attributes' do
    it 'has the correct attributes' do
      expect(specification).to respond_to(:shortlink)
      expect(specification).to respond_to(:description)
      expect(specification).to respond_to(:title)
      expect(specification).to respond_to(:shortname)
      expect(specification).to respond_to(:editor_draft)
      expect(specification).to respond_to(:series_version)
      expect(specification).to respond_to(:links)
    end

    it 'sets attributes correctly from hash' do
      expect(specification.shortlink).to eq('https://www.w3.org/TR/html5/')
      expect(specification.description).to include('This specification defines the 5th major revision')
      expect(specification.title).to eq('HTML 5.3')
      expect(specification.shortname).to eq('html5')
      expect(specification.editor_draft).to eq('https://w3c.github.io/html/')
      expect(specification.series_version).to eq('5.3')
    end
  end

  describe 'helper methods' do
    it 'returns the correct links' do
      expect(specification.links.self.href).to eq('https://api.w3.org/specifications/html5')
      expect(specification.links.version_history.href).to eq('https://api.w3.org/specifications/html5/versions')
      expect(specification.links.first_version.href).to eq('https://api.w3.org/specifications/html5/versions/20080122')
      expect(specification.links.first_version.title).to eq('Working Draft')
      expect(specification.links.latest_version.href).to eq('https://api.w3.org/specifications/html5/versions/20171214')
      expect(specification.links.latest_version.title).to eq('REC')
    end
  end

  xdescribe 'client methods' do
    let(:client) { instance_double(W3cApi::Client) }
    let(:versions) { [instance_double(W3cApi::Models::SpecVersion)] }

    it 'fetches versions using the client' do
      expect(client).to receive(:specification_versions).with('html5').and_return(versions)
      expect(specification.versions(client)).to eq(versions)
    end

    it 'returns nil when client is not provided' do
      expect(specification.versions).to be_nil
    end
  end

  describe 'serialization' do
    it 'can be converted to JSON' do
      json = specification.to_json
      expect(json).to be_a(String)
      expect(json).to include('"shortname":"html5"')
      expect(json).to include('"title":"HTML 5.3"')
    end

    it 'can be converted to YAML' do
      yaml = specification.to_yaml
      expect(yaml).to be_a(String)
      expect(yaml).to include('shortname: html5')
      expect(yaml).to include('title: HTML 5.3')
    end
  end
end
