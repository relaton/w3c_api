# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3c::Api::Client do
  let(:client) { described_class.new }
  let(:faraday_connection) { instance_double(Faraday::Connection) }
  let(:faraday_response) { instance_double(Faraday::Response) }

  before do
    allow(Faraday).to receive(:new).and_return(faraday_connection)
    allow(client).to receive(:create_connection).and_return(faraday_connection)
    allow(faraday_response).to receive(:status).and_return(200)
    allow(faraday_response).to receive(:body).and_return([])
    allow(faraday_response).to receive(:success?).and_return(true)
  end

  describe "#specifications" do
    let(:spec_data) do
      [
        {
          "shortname" => "html5",
          "title" => "HTML5",
          "series-version" => "5.3"
        }
      ]
    end

    before do
      allow(faraday_connection).to receive(:get).with("specifications", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(spec_data)
    end

    it "returns a list of specifications" do
      specifications = client.specifications
      expect(specifications).to be_an(Array)
      expect(specifications.first).to be_a(W3c::Api::Models::Specification)
      expect(specifications.first.shortname).to eq("html5")
      expect(specifications.first.title).to eq("HTML5")
    end
  end

  describe "#specification" do
    let(:spec_data) do
      {
        "shortname" => "html5",
        "title" => "HTML5",
        "series-version" => "5.3"
      }
    end

    before do
      allow(faraday_connection).to receive(:get).with("specifications/html5", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(spec_data)
    end

    it "returns a single specification" do
      specification = client.specification("html5")
      expect(specification).to be_a(W3c::Api::Models::Specification)
      expect(specification.shortname).to eq("html5")
      expect(specification.title).to eq("HTML5")
    end

    context "when specification does not exist" do
      before do
        allow(faraday_response).to receive(:status).and_return(404)
        allow(faraday_response).to receive(:success?).and_return(false)
      end

      it "raises a not found error" do
        expect { client.specification("nonexistent-specification") }.to raise_error(W3c::Api::NotFoundError)
      end
    end
  end

  describe "#groups" do
    let(:group_data) do
      [
        {
          "id" => 123,
          "name" => "HTML Working Group",
          "shortname" => "html",
          "type" => "working group"
        }
      ]
    end

    before do
      allow(faraday_connection).to receive(:get).with("groups", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(group_data)
    end

    it "returns a list of groups" do
      groups = client.groups
      expect(groups).to be_an(Array)
      expect(groups.first).to be_a(W3c::Api::Models::Group)
      expect(groups.first.id).to eq(123)
      expect(groups.first.name).to eq("HTML Working Group")
    end
  end

  describe "#group" do
    let(:group_data) do
      {
        "id" => 123,
        "name" => "HTML Working Group",
        "shortname" => "html",
        "type" => "working group"
      }
    end

    before do
      allow(faraday_connection).to receive(:get).with("groups/123", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(group_data)
    end

    it "returns a single group" do
      group = client.group(123)
      expect(group).to be_a(W3c::Api::Models::Group)
      expect(group.id).to eq(123)
      expect(group.name).to eq("HTML Working Group")
    end

    context "when group does not exist" do
      before do
        allow(faraday_response).to receive(:status).and_return(404)
        allow(faraday_response).to receive(:success?).and_return(false)
      end

      it "raises a not found error" do
        expect { client.group(999999) }.to raise_error(W3c::Api::NotFoundError)
      end
    end
  end

  describe "#users" do
    let(:user_data) do
      [
        {
          "id" => 456,
          "name" => "John Doe",
          "email" => "john@example.com"
        }
      ]
    end

    before do
      allow(faraday_connection).to receive(:get).with("users", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(user_data)
    end

    it "returns a list of users" do
      users = client.users
      expect(users).to be_an(Array)
      expect(users.first).to be_a(W3c::Api::Models::User)
      expect(users.first.id).to eq(456)
      expect(users.first.name).to eq("John Doe")
    end
  end

  describe "#user" do
    let(:user_data) do
      {
        "id" => 456,
        "name" => "John Doe",
        "email" => "john@example.com"
      }
    end

    before do
      allow(faraday_connection).to receive(:get).with("users/456", {}).and_return(faraday_response)
      allow(faraday_response).to receive(:body).and_return(user_data)
    end

    it "returns a single user" do
      user = client.user(456)
      expect(user).to be_a(W3c::Api::Models::User)
      expect(user.id).to eq(456)
      expect(user.name).to eq("John Doe")
    end

    context "when user does not exist" do
      before do
        allow(faraday_response).to receive(:status).and_return(404)
        allow(faraday_response).to receive(:success?).and_return(false)
      end

      it "raises a not found error" do
        expect { client.user(999999) }.to raise_error(W3c::Api::NotFoundError)
      end
    end
  end

  describe "error handling" do
    context "with a bad request" do
      before do
        allow(faraday_connection).to receive(:get).with("invalid-endpoint", { invalid: true }).and_return(faraday_response)
        allow(faraday_response).to receive(:status).and_return(400)
        allow(faraday_response).to receive(:success?).and_return(false)
      end

      it "raises a bad request error" do
        expect { client.get("invalid-endpoint", { invalid: true }) }.to raise_error(W3c::Api::BadRequestError)
      end
    end

    context "with a server error" do
      before do
        allow(faraday_connection).to receive(:get).with("some-endpoint", {}).and_return(faraday_response)
        allow(faraday_response).to receive(:status).and_return(500)
        allow(faraday_response).to receive(:success?).and_return(false)
        allow(faraday_response).to receive(:body).and_return({ "error" => "Server error" })
      end

      it "raises a server error" do
        expect { client.get("some-endpoint") }.to raise_error(W3c::Api::ServerError)
      end
    end
  end
end
