# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::SpecVersionPredecessorIndex do
  let(:client) { W3cApi::Client.new }

  describe '#predecessor_versions' do
    it 'returns predecessor versions for a specification version', :vcr do
      version = client.specification_version('html5', '20140429')
      predecessors = version.links.predecessor_versions.realize

      expect(predecessors).to be_a(described_class)
      expect(predecessors.links.predecessor_versions).to be_an(Array)
      expect(predecessors.links.predecessor_versions.length).to be > 0

      # Test that we can realize individual predecessor versions
      first_predecessor = predecessors.links.predecessor_versions.first.realize
      expect(first_predecessor).to be_a(W3cApi::Models::SpecVersion)
      expect(first_predecessor.title).to include('HTML5')
      expect(first_predecessor.date).to be_a(String)
    end

    it 'handles empty predecessor list gracefully', :vcr do
      # Test with a version that might not have predecessors
      version = client.specification_version('html5', '20121217')
      predecessors = version.links.predecessor_versions.realize

      expect(predecessors).to be_a(described_class)
      expect(predecessors.links.predecessor_versions).to be_an(Array)
    end
  end

  describe 'chained realization' do
    it 'allows chaining through multiple predecessor versions', :vcr do
      version = client.specification_version('html5', '20140429')
      predecessors = version.links.predecessor_versions.realize

      expect(predecessors).to be_a(described_class)

      # Navigate through each predecessor
      predecessors.links.predecessor_versions.each do |pred_link|
        predecessor = pred_link.realize
        expect(predecessor).to be_a(W3cApi::Models::SpecVersion)
        expect(predecessor.title).to be_a(String)
        expect(predecessor.date).to be_a(String)

        # Test that predecessor also has links (might have its own predecessors)
        expect(predecessor.links).to respond_to(:predecessor_versions)
        expect(predecessor.links).to respond_to(:successor_versions)
      end
    end
  end
end
