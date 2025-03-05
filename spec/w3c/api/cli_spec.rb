# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3c::Api::Cli do
  let(:thor_command) { described_class.new }

  describe 'specification commands' do
    let(:spec_command) { described_class::Specification.new }
    let(:client) { instance_double(W3c::Api::Client) }
    let(:specification) { instance_double(W3c::Api::Models::Specification) }

    before do
      allow(W3c::Api::Client).to receive(:new).and_return(client)
      allow(specification).to receive(:to_hash).and_return({
                                                             'shortname' => 'html5',
                                                             'title' => 'HTML5',
                                                             'series_version' => '5.3',
                                                             'editor_draft' => 'https://example.com/draft'
                                                           })
      allow(specification).to receive(:shortname).and_return('html5')
      allow(specification).to receive(:title).and_return('HTML5')
      allow(specification).to receive(:series_version).and_return('5.3')
      allow(specification).to receive(:editor_draft).and_return('https://example.com/draft')
      allow(specification).to receive(:is_a?).with(W3c::Api::Models::Specification).and_return(true)
    end

    describe '#fetch' do
      it 'outputs specification as a table by default' do
        expect(client).to receive(:specifications).and_return([specification])
        allow(spec_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { spec_command.fetch }.not_to raise_error
      end

      it 'outputs specification as JSON with --format=json' do
        expect(client).to receive(:specifications).and_return([specification])
        allow(spec_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { spec_command.invoke(:fetch, [], { format: 'json' }) }.not_to raise_error
      end

      it 'outputs specification as YAML with --format=yaml' do
        expect(client).to receive(:specifications).and_return([specification])
        allow(spec_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { spec_command.invoke(:fetch, [], { format: 'yaml' }) }.not_to raise_error
      end
    end
  end

  describe 'group commands' do
    let(:group_command) { described_class::Group.new }
    let(:client) { instance_double(W3c::Api::Client) }
    let(:group) { instance_double(W3c::Api::Models::Group) }

    before do
      allow(W3c::Api::Client).to receive(:new).and_return(client)
      allow(group).to receive(:to_hash).and_return({
                                                     'id' => 123,
                                                     'name' => 'Test Group',
                                                     'shortname' => 'test',
                                                     'type' => 'working group'
                                                   })
      allow(group).to receive(:id).and_return(123)
      allow(group).to receive(:name).and_return('Test Group')
      allow(group).to receive(:shortname).and_return('test')
      allow(group).to receive(:type).and_return('working group')
      allow(group).to receive(:is_a?).with(W3c::Api::Models::Group).and_return(true)
    end

    describe '#fetch' do
      it 'outputs group as a table by default' do
        expect(client).to receive(:groups).and_return([group])
        allow(group_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { group_command.fetch }.not_to raise_error
      end

      it 'outputs group as JSON with --format=json' do
        expect(client).to receive(:groups).and_return([group])
        allow(group_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { group_command.invoke(:fetch, [], { format: 'json' }) }.not_to raise_error
      end

      it 'outputs group as YAML with --format=yaml' do
        expect(client).to receive(:groups).and_return([group])
        allow(group_command).to receive(:client).and_return(client)
        allow(STDOUT).to receive(:puts)

        expect { group_command.invoke(:fetch, [], { format: 'yaml' }) }.not_to raise_error
      end
    end
  end
end
