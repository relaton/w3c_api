# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::Ecosystem do
  ecosystem_data_shared = {
    'name' => 'Data and knowledge',
    'shortname' => 'data',
    '_links' => {
      'self' => {
        'href' => 'https://api.w3.org/ecosystems/data',
        'type' => 'Ecosystem'
      },
      'champion' => {
        'href' => 'https://api.w3.org/users/t891ludoisggsccsw44o8goccc0s0ks',
        'title' => 'Pierre-Antoine Champin',
        'type' => 'User'
      },
      'evangelists' => {
        'href' => 'https://api.w3.org/ecosystems/data/evangelists',
        'type' => 'EvangelistIndex'
      },
      'groups' => {
        'href' => 'https://api.w3.org/ecosystems/data/groups',
        'type' => 'GroupIndex'
      },
      'member-organizations' => {
        'href' => 'https://api.w3.org/ecosystems/data/member-organizations',
        'type' => 'AffiliationIndex'
      }
    }
  }

  describe 'consistent HAL type naming' do
    let(:ecosystem_data) do
      ecosystem_data_shared
    end

    let(:ecosystem) { described_class.from_hash(ecosystem_data) }

    it 'creates an ecosystem with consistent link types' do
      expect(ecosystem.name).to eq('Data and knowledge')
      expect(ecosystem.shortname).to eq('data')
    end

    it 'produces consistent type names in HAL output' do
      # Convert back to hash to check serialization
      serialized = ecosystem.to_hash

      # All link types should be simple names without namespace prefixes
      links = serialized['_links']
      expect(links['groups']['type']).to eq('GroupIndex')
      expect(links['member-organizations']['type']).to eq('AffiliationIndex')
      expect(links['evangelists']['type']).to eq('EvangelistIndex')
      expect(links['champion']['type']).to eq('User')
      expect(links['self']['type']).to eq('Ecosystem')
    end

    it 'does not include namespace prefixes in type names' do
      serialized = ecosystem.to_hash
      links = serialized['_links']

      # Ensure no type contains the W3cApi::Models:: prefix
      links.each_value do |link_data|
        expect(link_data['type']).not_to include('W3cApi::Models::')
        expect(link_data['type']).not_to include('::')
      end
    end

    context 'when classes are loaded in different orders' do
      before do
        # Simulate different class loading scenarios
        # This ensures consistent behavior regardless of autoload order
        W3cApi::Models::EvangelistIndex
      end

      it 'maintains consistent type naming' do
        ecosystem1 = described_class.from_hash(ecosystem_data_shared)
        ecosystem2 = described_class.from_hash(ecosystem_data_shared)

        serialized1 = ecosystem1.to_hash
        serialized2 = ecosystem2.to_hash

        # Both should produce identical type names
        expect(serialized1['_links']['groups']['type']).to eq(serialized2['_links']['groups']['type'])
        expect(serialized1['_links']['member-organizations']['type']).to eq(serialized2['_links']['member-organizations']['type'])
      end
    end
  end

  describe 'automatic LinkSet creation' do
    it 'automatically creates EcosystemLinkSet class' do
      # The LinkSet class should be created automatically
      expect(W3cApi::Models::EcosystemLinkSet).to be_a(Class)
      expect(W3cApi::Models::EcosystemLinkSet).to be < Lutaml::Hal::LinkSet
    end

    it 'includes links attribute in the ecosystem class' do
      expect(described_class.attributes).to have_key(:links)
    end
  end

  describe 'link navigation' do
    let(:ecosystem) { described_class.from_hash(ecosystem_data_shared) }

    it 'provides access to link objects' do
      expect(ecosystem.links).to be_a(W3cApi::Models::EcosystemLinkSet)
      expect(ecosystem.links.groups).to be_a(Lutaml::Hal::Link)
      expect(ecosystem.links.member_organizations).to be_a(Lutaml::Hal::Link)
    end

    it 'preserves link href and type information' do
      expect(ecosystem.links.groups.href).to eq('https://api.w3.org/ecosystems/data/groups')
      expect(ecosystem.links.groups.type).to eq('GroupIndex')

      expect(ecosystem.links.member_organizations.href).to eq('https://api.w3.org/ecosystems/data/member-organizations')
      expect(ecosystem.links.member_organizations.type).to eq('AffiliationIndex')
    end
  end
end
