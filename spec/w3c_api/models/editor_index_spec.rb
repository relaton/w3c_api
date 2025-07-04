# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::EditorIndex do
  describe 'API integration', :vcr do
    let(:client) { W3cApi::Client.new }

    it 'fetches editors for a specification version' do
      VCR.use_cassette('specification_html5_version_20180327_editors') do
        version = client.specification_version('html5', '20180327')
        editors_index = version.links.editors.realize

        expect(editors_index).to be_a(described_class)
        expect(editors_index.links).to respond_to(:editors)
      end
    end

    it 'provides access to individual editors' do
      VCR.use_cassette('specification_html5_version_20180327_editors') do
        version = client.specification_version('html5', '20180327')
        editors_index = version.links.editors.realize

        editors = editors_index.links.editors
        expect(editors).to be_an(Array)
        expect(editors.length).to be > 0

        # Check that each editor is a User object
        editors.each do |editor_link|
          editor = editor_link.realize
          expect(editor).to be_a(W3cApi::Models::User)
          expect(editor).to respond_to(:name)
        end
      end
    end
  end

  describe 'collection behavior' do
    let(:editors_data) do
      {
        'page' => 1,
        'limit' => 100,
        'pages' => 1,
        'total' => 2,
        '_links' => {
          'editors' => [
            {
              'href' => 'https://api.w3.org/users/user1',
              'title' => 'Editor One'
            },
            {
              'href' => 'https://api.w3.org/users/user2',
              'title' => 'Editor Two'
            }
          ]
        }
      }
    end

    let(:editors_index) { described_class.from_json(editors_data.to_json) }

    it 'has editors collection' do
      expect(editors_index.links).to respond_to(:editors)
    end

    it 'provides access to editor links' do
      expect(editors_index.links.editors).to be_an(Array)
      expect(editors_index.links.editors.length).to eq(2)
    end

    it 'can realize individual editors' do
      editors_index.links.editors.each do |editor_link|
        expect(editor_link).to respond_to(:realize)
      end
    end
  end

  describe 'chained realization' do
    it 'allows chaining through multiple editor collections' do
      VCR.use_cassette('specification_html5_version_20180327_editors_chained') do
        client = W3cApi::Client.new
        version = client.specification_version('html5', '20180327')

        # Test that we can chain from version to editors to individual users
        editors_index = version.links.editors.realize
        expect(editors_index).to be_a(described_class)

        if editors_index.links.editors.any?
          first_editor = editors_index.links.editors.first.realize
          expect(first_editor).to be_a(W3cApi::Models::User)
        end
      end
    end
  end
end
