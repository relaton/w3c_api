# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe W3cApi::Commands::Affiliation do
  let(:affiliation_command) { described_class.new }
  let(:client) { instance_double(W3cApi::Client) }
  let(:affiliation) { instance_double(W3cApi::Models::Affiliation) }
  let(:affiliations) { instance_double(W3cApi::Models::AffiliationIndex) }
  let(:users) { instance_double(W3cApi::Models::UserIndex) }
  let(:participations) { instance_double(W3cApi::Models::ParticipationIndex) }

  before do
    allow(W3cApi::Client).to receive(:new).and_return(client)
    allow(affiliation).to receive(:to_yaml).and_return("---\nid: 35662\nname: Google LLC\nmember: true\n")
    allow(affiliation).to receive(:to_json).and_return('{"id":35662,"name":"Google LLC","member":true}')
    allow(affiliations).to receive(:to_yaml).and_return("---\n- id: 35662\n  name: Google LLC\n  member: true\n")
    allow(affiliations).to receive(:to_json).and_return('[{"id":35662,"name":"Google LLC","member":true}]')
    allow(users).to receive(:to_yaml).and_return("---\n- id: 123\n  name: John Doe\n")
    allow(users).to receive(:to_json).and_return('[{"id":123,"name":"John Doe"}]')
    allow(participations).to receive(:to_yaml).and_return("---\n- id: 987\n  joined: 2020-01-01\n")
    allow(participations).to receive(:to_json).and_return('[{"id":987,"joined":"2020-01-01"}]')
  end

  describe '#fetch', :vcr do
    before do
      # Stub STDOUT to capture output
      @original_stdout = $stdout
      $stdout = StringIO.new
    end

    after do
      $stdout = @original_stdout
    end

    it 'outputs affiliations' do
      # Mock the client and response
      expect(client).to receive(:affiliations).and_return(affiliations)
      allow(affiliation_command).to receive(:client).and_return(client)

      # We're not going to try to mock the format_output method
      # Instead, just verify that it doesn't raise an error and outputs something
      expect { affiliation_command.fetch }.not_to raise_error
      expect($stdout.string).not_to be_empty
    end

    it 'outputs a single affiliation when id is provided' do
      expect(client).to receive(:affiliation).with(35_662).and_return(affiliation)
      allow(affiliation_command).to receive(:client).and_return(client)

      expect { affiliation_command.invoke(:fetch, [], { id: 35_662 }) }.not_to raise_error
      expect($stdout.string).to include('name: Google LLC')
    end

    it 'outputs affiliation as JSON with --format=json' do
      expect(client).to receive(:affiliations).and_return(affiliations)
      allow(affiliation_command).to receive(:client).and_return(client)

      expect { affiliation_command.invoke(:fetch, [], { format: 'json' }) }.not_to raise_error
      expect($stdout.string).to include('"name":"Google LLC"')
    end
  end

  describe '#participants' do
    before do
      @original_stdout = $stdout
      $stdout = StringIO.new
    end

    after do
      $stdout = @original_stdout
    end

    it 'outputs participants of an affiliation' do
      expect(client).to receive(:affiliation_participants).with(35_662).and_return(users)
      allow(affiliation_command).to receive(:client).and_return(client)

      expect { affiliation_command.invoke(:participants, [], { id: 35_662 }) }.not_to raise_error
      expect($stdout.string).to include('name: John Doe')
    end
  end

  describe '#participations' do
    before do
      @original_stdout = $stdout
      $stdout = StringIO.new
    end

    after do
      $stdout = @original_stdout
    end

    it 'outputs participations of an affiliation' do
      expect(client).to receive(:affiliation_participations).with(35_662).and_return(participations)
      allow(affiliation_command).to receive(:client).and_return(client)

      expect { affiliation_command.invoke(:participations, [], { id: 35_662 }) }.not_to raise_error
      expect($stdout.string).to include('joined: 2020-01-01')
    end
  end
end
