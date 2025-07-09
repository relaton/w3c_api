# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Models::GroupIndex do
  describe "API integration" do
    let(:client) { W3cApi::Client.new }
    let(:mock_groups) do
      mock_data = {
        "page": 1,
        "limit": 100,
        "pages": 3,
        "total": 257,
        "_links": {
          "groups": [
            {
              "href": "https://api.w3.org/groups/tf/ab-liaisons-to-bod",
              "title": "AB Liaisons to the Board of Directors",
            },
            {
              "href": "https://api.w3.org/groups/cg/a11yedge",
              "title": "Accessibility at the Edge Community Group",
            },
            {
              "href": "https://api.w3.org/groups/tf/wcag-act",
              "title": "Accessibility Conformance Testing (ACT) Task Force",
            },
            {
              "href": "https://api.w3.org/groups/cg/a11y-discov-vocab",
              "title": "Accessibility Discoverability Vocabulary for Schema.org Community Group",
            },
            {
              "href": "https://api.w3.org/groups/cg/accessibility4children",
              "title": "Accessibility for Children Community Group",
            },
            {
              "href": "https://api.w3.org/groups/wg/ag",
              "title": "Accessibility Guidelines Working Group",
            },
          ],
        },
      }
      W3cApi::Models::GroupIndex.from_json(mock_data.to_json)
    end

    it "fetches all groups" do
      # Skip real API call and return a mock object
      allow(client).to receive(:groups).and_return(mock_groups)

      groups = client.groups.links.groups
      expect(client.groups).to be_a(W3cApi::Models::GroupIndex)
      expect(groups.size).to be > 0
      expect(groups.first).to be_a(W3cApi::Models::GroupLink)
      expect(groups.first.title).to eq("AB Liaisons to the Board of Directors")
    end
  end

  let(:groups_hash) do
    {
      "page": 1,
      "limit": 100,
      "pages": 3,
      "total": 257,
      "_links": {
        "groups": [
          {
            "href": "https://api.w3.org/groups/tf/ab-liaisons-to-bod",
            "title": "AB Liaisons to the Board of Directors",
          },
          {
            "href": "https://api.w3.org/groups/cg/a11yedge",
            "title": "Accessibility at the Edge Community Group",
          },
          {
            "href": "https://api.w3.org/groups/tf/wcag-act",
            "title": "Accessibility Conformance Testing (ACT) Task Force",
          },
          {
            "href": "https://api.w3.org/groups/cg/a11y-discov-vocab",
            "title": "Accessibility Discoverability Vocabulary for Schema.org Community Group",
          },
          {
            "href": "https://api.w3.org/groups/cg/accessibility4children",
            "title": "Accessibility for Children Community Group",
          },
          {
            "href": "https://api.w3.org/groups/wg/ag",
            "title": "Accessibility Guidelines Working Group",
          },
        ],
      },
    }
  end

  let(:groups) do
    described_class.from_json(groups_hash.to_json)
  end

  describe "enumeration" do
    it "acts as an enumerable" do
      expect(groups.links.groups).to respond_to(:each)
      expect(groups.links.groups).to respond_to(:map)
      expect(groups.links.groups).to respond_to(:select)
      expect(groups.links.groups.to_a).to be_an(Array)
      expect(groups.links.groups.to_a.size).to eq(6)
    end

    it "yields group objects" do
      groups.links.groups.each do |group|
        expect(group).to be_a(W3cApi::Models::GroupLink)
      end
    end
  end

  describe "accessing elements" do
    it "allows accessing elements by index" do
      expect(groups.links.groups.first).to be_a(W3cApi::Models::GroupLink)
      expect(groups.links.groups.first.href).to be_eql("https://api.w3.org/groups/tf/ab-liaisons-to-bod")
    end

    it "provides a first method" do
      expect(groups.links.groups.first).to be_a(W3cApi::Models::GroupLink)
      expect(groups.links.groups.first.href).to be_eql("https://api.w3.org/groups/tf/ab-liaisons-to-bod")
    end

    it "has the correct size" do
      expect(groups.links.groups.size).to eq(6)
    end
  end

  describe "serialization" do
    it "can be converted to JSON" do
      json = groups.to_json
      expect(json).to include('"page":1')
      expect(json).to include('"total":257')
      expect(json).to include('"title":"AB Liaisons to the Board of Directors"')
    end

    it "can be converted to YAML" do
      yaml = groups.to_yaml
      expect(yaml).to include("page: 1")
      expect(yaml).to include("total: 257")
      expect(yaml).to include("title: AB Liaisons to the Board of Directors")
    end
  end
end
