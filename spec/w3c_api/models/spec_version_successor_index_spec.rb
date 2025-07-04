# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Models::SpecVersionSuccessorIndex do
  let(:client) { W3cApi::Client.new }

  describe '#successor_versions' do
    it 'returns successor versions for a specification version', :vcr do
      version = client.specification_version('html5', '20140429')
      successors = version.links.successor_versions.realize

      expect(successors).to be_a(described_class)
      expect(successors.links.successor_versions).to be_an(Array)
      expect(successors.links.successor_versions.length).to be > 0

      # Test that we can realize individual successor versions
      first_successor = successors.links.successor_versions.first.realize
      expect(first_successor).to be_a(W3cApi::Models::SpecVersion)
      expect(first_successor.title).to include('HTML5')
      expect(first_successor.date).to be_a(String)
    end

    it 'handles empty successor list gracefully', :vcr do
      # Test with the latest version that might not have successors
      version = client.specification_version('html5', '20141028')
      successors = version.links.successor_versions.realize

      expect(successors).to be_a(described_class)
      expect(successors.links.successor_versions).to be_an(Array)
    end
  end

  describe 'chained realization' do
    it 'allows chaining through multiple successor versions', :vcr do
      version = client.specification_version('html5', '20140429')
      successors = version.links.successor_versions.realize

      expect(successors).to be_a(described_class)

      # Navigate through each successor
      successors.links.successor_versions.each do |succ_link|
        successor = succ_link.realize
        expect(successor).to be_a(W3cApi::Models::SpecVersion)
        expect(successor.title).to be_a(String)
        expect(successor.date).to be_a(String)

        # Test that successor also has links (might have its own successors)
        expect(successor.links).to respond_to(:predecessor_versions)
        expect(successor.links).to respond_to(:successor_versions)
      end
    end
  end

  describe 'navigation between versions' do
    it 'allows navigation from predecessor to successor and back', :vcr do
      # Start with a middle version that has both predecessors and successors
      version = client.specification_version('html5', '20140429')

      # Get predecessors
      predecessors = version.links.predecessor_versions.realize
      expect(predecessors.links.predecessor_versions.length).to be > 0

      # Get successors
      successors = version.links.successor_versions.realize
      expect(successors.links.successor_versions.length).to be > 0

      # Navigate to a predecessor
      predecessor = predecessors.links.predecessor_versions.first.realize
      expect(predecessor.date).to be < version.date

      # Navigate to a successor
      successor = successors.links.successor_versions.first.realize
      expect(successor.date).to be > version.date
    end
  end
end
