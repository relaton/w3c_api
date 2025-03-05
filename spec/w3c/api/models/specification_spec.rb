# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3c::Api::Models::Specification do
  let(:spec_hash) do
    {
      "shortlink" => "https://www.w3.org/TR/html5/",
      "description" => "HTML specification",
      "title" => "HTML 5.3",
      "shortname" => "html5",
      "editor-draft" => "https://w3c.github.io/html/",
      "series-version" => "5.3",
      "_links" => {
        "self" => {
          "href" => "https://api.w3.org/specifications/html5"
        },
        "version-history" => {
          "href" => "https://api.w3.org/specifications/html5/versions"
        },
        "latest-version" => {
          "href" => "https://api.w3.org/specifications/html5/versions/20171214",
          "title" => "REC"
        }
      }
    }
  end

  let(:specification) { described_class.from_response(spec_hash) }

  describe "attributes" do
    it "has the correct attributes" do
      expect(specification).to respond_to(:shortlink)
      expect(specification).to respond_to(:description)
      expect(specification).to respond_to(:title)
      expect(specification).to respond_to(:shortname)
      expect(specification).to respond_to(:editor_draft)
      expect(specification).to respond_to(:series_version)
      expect(specification).to respond_to(:_links)
    end

    it "sets attributes correctly from hash" do
      expect(specification.shortlink).to eq("https://www.w3.org/TR/html5/")
      expect(specification.description).to eq("HTML specification")
      expect(specification.title).to eq("HTML 5.3")
      expect(specification.shortname).to eq("html5")
      expect(specification.editor_draft).to eq("https://w3c.github.io/html/")
      expect(specification.series_version).to eq("5.3")
    end
  end

  describe "helper methods" do
    it "returns the correct links" do
      expect(specification.self_url).to eq("https://api.w3.org/specifications/html5")
      expect(specification.version_history_url).to eq("https://api.w3.org/specifications/html5/versions")
      expect(specification.latest_version_url).to eq("https://api.w3.org/specifications/html5/versions/20171214")
      expect(specification.latest_version_title).to eq("REC")
    end
  end

  describe "versions" do
    let(:client) { instance_double(W3c::Api::Client) }
    let(:versions) { [instance_double(W3c::Api::Models::SpecVersion)] }

    it "fetches versions using the client" do
      expect(client).to receive(:specification_versions).with("html5").and_return(versions)
      expect(specification.versions(client)).to eq(versions)
    end
  end

  describe "serialization" do
    it "can be converted to XML and YAML" do
      expect { specification.to_xml }.not_to raise_error
      expect { specification.to_yaml }.not_to raise_error
    end

    it "can iterate through attributes" do
      attributes = []
      described_class.attributes.each do |attr|
        attributes << attr.name if specification.respond_to?(attr.name)
      end
      expect(attributes).to include(:shortname)
      expect(attributes).to include(:title)
    end
  end
end
