# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Models::Serie do
  describe "API integration", :vcr do
    let(:client) { W3cApi::Client.new }

    it "fetches HTML specification series" do
      VCR.use_cassette("model_series_html") do
        series = client.series_by_shortname("html")
        expect(series).to be_a(W3cApi::Models::Serie)
        expect(series.shortname).to eq("html")
        expect(series.name).to include("HTML")
        expect(series.links.self.href).to include("html")
      end
    end

    it "fetches specifications in a series" do
      VCR.use_cassette("model_series_html_specifications") do
        series = client.series_by_shortname("html")
        specifications = series.links.specifications
        expect(specifications.class.name).to be_eql("W3cApi::Models::SpecificationIndexLink")
        expect(specifications.href).to be_eql("https://api.w3.org/specification-series/html/specifications")
      end
    end
  end
  let(:series_hash) do
    {
      "shortname" => "webrtc",
      "name" => "WebRTC: Real-Time Communication Between Browsers",
      "_links" => {
        "self" => {
          "href" => "https://api.w3.org/specification-series/webrtc",
        },
        "specifications" => {
          "href" => "https://api.w3.org/specification-series/webrtc/specifications",
        },
        "current-specification" => {
          "href" => "https://api.w3.org/specifications/webrtc",
        },
      },
    }
  end

  let(:series) { described_class.from_json(series_hash.to_json) }

  describe "attributes" do
    it "has the correct attributes" do
      expect(series).to respond_to(:shortname)
      expect(series).to respond_to(:name)
      expect(series).to respond_to(:links)
    end

    it "sets attributes correctly from hash" do
      expect(series.shortname).to eq("webrtc")
      expect(series.name).to eq("WebRTC: Real-Time Communication Between Browsers")
    end
  end

  describe "helper methods" do
    it "returns the correct links" do
      expect(series.links.self.href).to eq("https://api.w3.org/specification-series/webrtc")
      expect(series.links.specifications.href).to eq("https://api.w3.org/specification-series/webrtc/specifications")
      expect(series.links.current_specification.href).to eq("https://api.w3.org/specifications/webrtc")
    end
  end

  describe "specifications" do
    let(:client) { instance_double(W3cApi::Client) }
    let(:specifications) { [instance_double(W3cApi::Models::Specification)] }

    it "fetches specifications using the client" do
      expect(client).to receive(:series_specifications).with("webrtc").and_return(specifications)
      expect(series.specifications(client)).to eq(specifications)
    end
  end

  describe "current_specification" do
    let(:client) { instance_double(W3cApi::Client) }
    let(:specification) { instance_double(W3cApi::Models::Specification) }

    it "fetches current specification using the client" do
      expect(client).to receive(:specification).with("webrtc").and_return(specification)
      expect(series.current_specification(client)).to eq(specification)
    end
  end

  describe "serialization" do
    it "can be converted to JSON and YAML" do
      expect { series.to_json }.not_to raise_error
      expect { series.to_yaml }.not_to raise_error
    end
  end
end
