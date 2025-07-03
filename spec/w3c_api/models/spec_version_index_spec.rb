# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Models::SpecVersionIndex do
  let(:spec_version_index_hash) do
    {
      "total" => 2,
      "page" => 1,
      "pages" => 1,
      "limit" => 25,
      "_links" => {
        "self" => {
          "href" => "https://api.w3.org/specifications/html5/versions",
        },
        "predecessor-version" => [
          {
            "href" => "https://api.w3.org/specifications/html5/versions/20171214",
            "title" => "HTML 5.2",
          },
        ],
        "successor-version" => [
          {
            "href" => "https://api.w3.org/specifications/html5/versions/20180327",
            "title" => "HTML 5.3",
          },
        ],
      },
    }
  end

  let(:spec_version_index) do
    described_class.from_json(spec_version_index_hash.to_json)
  end

  describe "attributes" do
    it "has the correct attributes" do
      expect(spec_version_index).to respond_to(:total)
      expect(spec_version_index).to respond_to(:page)
      expect(spec_version_index).to respond_to(:pages)
      expect(spec_version_index).to respond_to(:limit)
      expect(spec_version_index).to respond_to(:links)
    end

    it "sets attributes correctly from hash" do
      expect(spec_version_index.total).to eq(2)
      expect(spec_version_index.page).to eq(1)
      expect(spec_version_index.pages).to eq(1)
      expect(spec_version_index.limit).to eq(25)
    end
  end

  describe "HAL links" do
    it "returns the correct self link" do
      expect(spec_version_index.links.self.href).to eq("https://api.w3.org/specifications/html5/versions")
    end

    it "has predecessor_version links" do
      expect(spec_version_index.links).to respond_to(:predecessor_version)
      expect(spec_version_index.links.predecessor_version).to be_a(Array)
      expect(spec_version_index.links.predecessor_version.first).to be_a(W3cApi::Models::SpecVersionIndexLink)
      expect(spec_version_index.links.predecessor_version.first.href).to eq("https://api.w3.org/specifications/html5/versions/20171214")
      expect(spec_version_index.links.predecessor_version.first.title).to eq("HTML 5.2")
    end

    it "has successor_version links" do
      expect(spec_version_index.links).to respond_to(:successor_version)
      expect(spec_version_index.links.successor_version).to be_a(Array)
      expect(spec_version_index.links.successor_version.first).to be_a(W3cApi::Models::SpecVersionIndexLink)
      expect(spec_version_index.links.successor_version.first.href).to eq("https://api.w3.org/specifications/html5/versions/20180327")
      expect(spec_version_index.links.successor_version.first.title).to eq("HTML 5.3")
    end
  end

  describe "HAL link realization" do
    context "when predecessor_version links exist" do
      it "has realize method available" do
        # The key fix is that these links now have the realize method available
        # without throwing "Unregistered URL pattern" errors
        expect(spec_version_index.links.predecessor_version.first).to respond_to(:realize)
      end
    end

    context "when successor_version links exist" do
      it "has realize method available" do
        # The key fix is that these links now have the realize method available
        # without throwing "Unregistered URL pattern" errors
        expect(spec_version_index.links.successor_version.first).to respond_to(:realize)
      end
    end
  end

  describe "serialization" do
    it "can be converted to JSON" do
      json = spec_version_index.to_json
      expect(json).to be_a(String)
      expect(json).to include('"total":2')
      expect(json).to include('"page":1')
    end

    it "can be converted to YAML" do
      yaml = spec_version_index.to_yaml
      expect(yaml).to be_a(String)
      expect(yaml).to include("total: 2")
      expect(yaml).to include("page: 1")
    end
  end
end
