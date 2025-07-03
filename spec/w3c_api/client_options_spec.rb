# frozen_string_literal: true

require 'spec_helper'

RSpec.describe W3cApi::Client, 'options support' do
  let(:client) { described_class.new }
  let(:mock_register) { instance_double(Lutaml::Hal::ModelRegister) }

  before do
    allow(W3cApi::Hal.instance).to receive(:register).and_return(mock_register)
  end

  describe 'pagination options' do
    it 'passes page parameter to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:specification_index, page: 2)
      client.specifications(page: 2)
    end

    it 'passes per_page parameter to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:specification_index, per_page: 50)
      client.specifications(per_page: 50)
    end

    it 'passes limit parameter to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:group_index, limit: 25)
      client.groups(limit: 25)
    end

    it 'passes offset parameter to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:affiliation_index, offset: 100)
      client.affiliations(offset: 100)
    end

    it 'passes multiple pagination parameters together' do
      expect(mock_register).to receive(:fetch).with(:specification_index, page: 3, per_page: 20, offset: 40)
      client.specifications(page: 3, per_page: 20, offset: 40)
    end
  end

  describe 'HTTP client options' do
    it 'passes custom headers to the HAL client' do
      headers = { 'User-Agent' => 'MyApp/1.0', 'Accept' => 'application/hal+json' }
      expect(mock_register).to receive(:fetch).with(:user_resource, hash: 'test123', headers: headers)
      client.user('test123', headers: headers)
    end

    it 'passes timeout options to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:group_resource, id: 123, timeout: 30)
      client.group(123, timeout: 30)
    end

    it 'passes read_timeout options to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:specification_resource, shortname: 'html5', read_timeout: 45)
      client.specification('html5', read_timeout: 45)
    end

    it 'passes open_timeout options to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:translation_index, open_timeout: 10)
      client.translations(open_timeout: 10)
    end
  end

  describe 'query parameter options' do
    it 'passes custom query parameters to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:specification_by_status_index, status: 'REC', sort: 'date',
                                                                                    order: 'desc')
      client.specifications_by_status('REC', sort: 'date', order: 'desc')
    end

    it 'passes filter parameters to the HAL client' do
      expect(mock_register).to receive(:fetch).with(:group_index, type: 'working-group', status: 'active')
      client.groups(type: 'working-group', status: 'active')
    end
  end

  describe 'option combinations' do
    it 'handles pagination and HTTP options together' do
      options = {
        page: 2,
        per_page: 25,
        headers: { 'User-Agent' => 'TestApp/2.0' },
        timeout: 60
      }
      expect(mock_register).to receive(:fetch).with(:specification_index, **options)
      client.specifications(options)
    end

    it 'handles all types of options together' do
      options = {
        page: 1,
        limit: 10,
        headers: { 'Accept-Language' => 'en-US' },
        timeout: 30,
        sort: 'name',
        filter: 'active'
      }
      expect(mock_register).to receive(:fetch).with(:group_index, **options)
      client.groups(options)
    end
  end

  describe 'backward compatibility' do
    it 'works without any options (empty hash)' do
      expect(mock_register).to receive(:fetch).with(:specification_index)
      client.specifications
    end

    it 'works with empty options hash' do
      expect(mock_register).to receive(:fetch).with(:specification_index)
      client.specifications({})
    end

    it 'preserves existing functionality for required parameters' do
      expect(mock_register).to receive(:fetch).with(:specification_resource, shortname: 'html5')
      client.specification('html5')
    end

    it 'combines required parameters with options' do
      expect(mock_register).to receive(:fetch).with(
        :specification_resource,
        shortname: 'html5',
        page: 1,
        headers: { 'Accept' => 'application/json' }
      )
      client.specification('html5', page: 1, headers: { 'Accept' => 'application/json' })
    end
  end

  describe 'method-specific option passing' do
    context 'specification methods' do
      it 'passes options to specification' do
        expect(mock_register).to receive(:fetch).with(
          :specification_resource,
          shortname: 'webrtc',
          timeout: 20
        )
        client.specification('webrtc', timeout: 20)
      end

      it 'passes options to specification_versions' do
        expect(mock_register).to receive(:fetch).with(
          :specification_resource_version_index,
          shortname: 'webrtc',
          page: 2
        )
        client.specification_versions('webrtc', page: 2)
      end

      it 'passes options to specification_version' do
        expect(mock_register).to receive(:fetch).with(
          :specification_resource_version_resource,
          shortname: 'webrtc',
          version: '20241008',
          headers: { 'Cache-Control' => 'no-cache' }
        )
        client.specification_version('webrtc', '20241008', headers: { 'Cache-Control' => 'no-cache' })
      end
    end

    context 'group methods' do
      it 'passes options to group_specifications' do
        expect(mock_register).to receive(:fetch).with(:group_specifications_index, id: 123, per_page: 15)
        client.group_specifications(123, per_page: 15)
      end

      it 'passes options to group_users' do
        expect(mock_register).to receive(:fetch).with(:group_users_index, id: 456, limit: 50)
        client.group_users(456, limit: 50)
      end
    end

    context 'user methods' do
      it 'passes options to user_groups' do
        expect(mock_register).to receive(:fetch).with(:user_groups_index, hash: 'abc123', page: 1, per_page: 10)
        client.user_groups('abc123', page: 1, per_page: 10)
      end

      it 'passes options to user_specifications' do
        expect(mock_register).to receive(:fetch).with(:user_specifications_index, hash: 'def456', sort: 'title')
        client.user_specifications('def456', sort: 'title')
      end
    end

    context 'ecosystem methods' do
      it 'passes options to ecosystem_groups' do
        expect(mock_register).to receive(:fetch).with(:ecosystem_groups_index, shortname: 'data', page: 2)
        client.ecosystem_groups('data', page: 2)
      end
    end
  end

  describe 'edge cases' do
    it 'handles nil options gracefully' do
      expect(mock_register).to receive(:fetch).with(:specification_index)
      client.specifications(nil)
    end

    it 'handles options with nil values' do
      expect(mock_register).to receive(:fetch).with(:specification_index, page: nil, per_page: 10)
      client.specifications(page: nil, per_page: 10)
    end

    it 'handles string keys in options' do
      expect(mock_register).to receive(:fetch).with(:specification_index, 'page' => 1, 'per_page' => 20)
      client.specifications('page' => 1, 'per_page' => 20)
    end
  end
end
