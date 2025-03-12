# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::Affiliation do
  let(:affiliation_hash) do
    {
      'id' => 123,
      'name' => 'Example Organization',
      'title' => 'Example Organization Title',
      'href' => 'https://api.w3.org/affiliations/123',
      'descr' => 'organization',
      'is-member' => true,
      'is-member-association' => false,
      'is-partner-member' => true,
      '_links' => {
        'self' => {
          'href' => 'https://api.w3.org/affiliations/123'
        },
        'participants' => {
          'href' => 'https://api.w3.org/affiliations/123/participants'
        },
        'participations' => {
          'href' => 'https://api.w3.org/affiliations/123/participations'
        }
      }
    }
  end

  let(:affiliation) { described_class.from_json(affiliation_hash.to_json) }

  describe 'attributes' do
    it 'has the correct attributes' do
      expect(affiliation).to respond_to(:id)
      expect(affiliation).to respond_to(:name)
      expect(affiliation).to respond_to(:title)
      expect(affiliation).to respond_to(:href)
      expect(affiliation).to respond_to(:descr)
      expect(affiliation).to respond_to(:is_member)
      expect(affiliation).to respond_to(:is_member_association)
      expect(affiliation).to respond_to(:is_partner_member)
      expect(affiliation).to respond_to(:_links)
    end

    it 'sets attributes correctly from hash' do
      expect(affiliation.id).to eq(123)
      expect(affiliation.name).to eq('Example Organization')
      expect(affiliation.title).to eq('Example Organization Title')
      expect(affiliation.href).to eq('https://api.w3.org/affiliations/123')
      expect(affiliation.descr).to eq('organization')
      expect(affiliation.is_member).to be true
      expect(affiliation.is_member_association).to be false
      expect(affiliation.is_partner_member).to be true
    end
  end

  describe 'helper methods' do
    it 'returns the correct links' do
      expect(affiliation.links.self.href).to eq('https://api.w3.org/affiliations/123')
      expect(affiliation.links.participants.href).to eq('https://api.w3.org/affiliations/123/participants')
      expect(affiliation.links.participations.href).to eq('https://api.w3.org/affiliations/123/participations')
    end
  end

  describe 'participants' do
    let(:client) { instance_double(W3cApi::Client) }
    let(:participants) { [instance_double(W3cApi::Models::User)] }

    it 'fetches participants using the client' do
      expect(client).to receive(:affiliation_participants).with(123).and_return(participants)
      expect(affiliation.participants(client)).to eq(participants)
    end
  end

  describe 'participations' do
    let(:client) { instance_double(W3cApi::Client) }
    let(:participations) { [instance_double(W3cApi::Models::Participation)] }

    it 'fetches participations using the client' do
      expect(client).to receive(:affiliation_participations).with(123).and_return(participations)
      expect(affiliation.participations(client)).to eq(participations)
    end
  end

  describe 'serialization' do
    it 'can be converted to JSON and YAML' do
      expect { affiliation.to_json }.not_to raise_error
      expect { affiliation.to_yaml }.not_to raise_error
    end
  end
end
