# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::Groups do
  describe 'API integration' do
    let(:client) { W3cApi::Client.new }
    let(:mock_groups) do
      mock_data = {
        'page' => 1,
        'pages' => 5,
        'total' => 257,
        '_links' => {
          'groups' => [
            {
              'id' => 123_456,
              'name' => 'Accessibility Guidelines Working Group',
              'type' => 'working group',
              'shortname' => 'ag',
              '_links' => {
                'self' => {
                  'href' => 'https://api.w3.org/groups/wg/ag'
                }
              }
            },
            {
              'id' => 789_012,
              'name' => 'Web Performance Working Group',
              'type' => 'working group',
              'shortname' => 'webperf',
              '_links' => {
                'self' => {
                  'href' => 'https://api.w3.org/groups/wg/webperf'
                }
              }
            }
          ]
        }
      }
      W3cApi::Models::Groups.from_response(mock_data['_links']['groups'])
    end

    it 'fetches all groups' do
      # Skip real API call and return a mock object
      allow(client).to receive(:groups).and_return(mock_groups)

      groups = client.groups.groups
      expect(groups).to be_a(Array)
      expect(groups.size).to be > 0
      expect(groups.first).to be_a(W3cApi::Models::Group)
      expect(groups.first.name).to eq('Accessibility Guidelines Working Group')
    end
  end

  let(:groups_hash) do
    {
      'page' => 1,
      'pages' => 5,
      'total' => 121,
      '_links' => {
        'groups' => [
          {
            'id' => 109_735,
            'name' => 'Immersive Web Working Group',
            'type' => 'working group',
            'shortname' => 'immersive-web',
            '_links' => {
              'self' => {
                'href' => 'https://api.w3.org/groups/109735'
              }
            }
          },
          {
            'id' => 110_599,
            'name' => 'Web Machine Learning Working Group',
            'type' => 'working group',
            'shortname' => 'webmachinelearning',
            '_links' => {
              'self' => {
                'href' => 'https://api.w3.org/groups/110599'
              }
            }
          }
        ]
      }
    }
  end

  let(:groups) do
    g = described_class.new
    g.groups = groups_hash['_links']['groups'].map { |item| W3cApi::Models::Group.from_response(item) }
    g
  end

  describe 'enumeration' do
    it 'acts as an enumerable' do
      expect(groups).to respond_to(:each)
      expect(groups).to respond_to(:map)
      expect(groups).to respond_to(:select)
      expect(groups.to_a).to be_an(Array)
      expect(groups.to_a.size).to eq(2)
    end

    it 'yields group objects' do
      groups.each do |group|
        expect(group).to be_a(W3cApi::Models::Group)
      end
    end
  end

  describe 'accessing elements' do
    it 'allows accessing elements by index' do
      expect(groups[0]).to be_a(W3cApi::Models::Group)
      expect(groups[0].id).to eq(109_735)
      expect(groups[1].id).to eq(110_599)
    end

    it 'provides a first method' do
      expect(groups.first).to be_a(W3cApi::Models::Group)
      expect(groups.first.id).to eq(109_735)
    end

    it 'has the correct size' do
      expect(groups.size).to eq(2)
      expect(groups.length).to eq(2)
      expect(groups.count).to eq(2)
    end

    it 'reports empty state correctly' do
      expect(groups.empty?).to be(false)
      expect(described_class.from_response({ '_links' => { 'groups' => [] } }).empty?).to be(true)
    end
  end

  describe 'serialization' do
    it 'can be converted to JSON' do
      json = groups.to_json
      expect(json).to include('"id":109735')
      expect(json).to include('"name":"Immersive Web Working Group"')
      expect(json).to include('"name":"Web Machine Learning Working Group"')
    end

    it 'can be converted to YAML' do
      yaml = groups.to_yaml
      expect(yaml).to include('id: 109735')
      expect(yaml).to include('name: Immersive Web Working Group')
      expect(yaml).to include('name: Web Machine Learning Working Group')
    end
  end
end
