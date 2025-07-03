# frozen_string_literal: true

require "spec_helper"

RSpec.describe W3cApi::Models::Group do
  let(:group) { described_class.from_json(group_hash.to_json) }
  let(:group_hash) do
    {
      "id" => 109_735,
      "name" => "Immersive Web Working Group",
      "type" => "working group",
      "description" => "The Immersive Web Working Group aims to develop standards",
      "shortname" => "immersive-web",
      "discr" => "w3cgroup",
      "_links" => {
        "self" => {
          "href" => "https://api.w3.org/groups/109735",
        },
        "homepage" => {
          "href" => "https://www.w3.org/immersive-web/",
        },
        "users" => {
          "href" => "https://api.w3.org/groups/109735/users",
        },
        "specifications" => {
          "href" => "https://api.w3.org/groups/109735/specifications",
        },
        "chairs" => {
          "href" => "https://api.w3.org/groups/109735/chairs",
        },
        "team-contacts" => {
          "href" => "https://api.w3.org/groups/109735/team-contacts",
        },
      },
    }
  end

  describe "API integration", :vcr do
    let(:client) { W3cApi::Client.new }

    it "fetches a specific group" do
      VCR.use_cassette("model_group_109735") do
        group = client.group(109_735) # Immersive Web Working Group
        expect(group).to be_a(described_class)
        expect(group.name).to eq("Immersive Web Working Group")
        expect(group.links.self.href).to include("immersive-web") # API now returns path with shortname instead of ID
      end
    end

    it "fetches users in a group" do
      VCR.use_cassette("model_group_109735_users") do
        group = client.group(109_735)
        users = group.links.users
        expect(users.class.name).to eql("W3cApi::Models::UserIndexLink")
        expect(users.href).to include("immersive-web/users")
        # expect(users.first).to be_a(W3cApi::Models::UserLink)
      end
    end

    it "fetches specifications of a group" do
      VCR.use_cassette("model_group_109735_specifications") do
        group = client.group(109_735)
        specifications = group.links.specifications
        expect(specifications.class.name).to eql("W3cApi::Models::SpecificationIndexLink")
        expect(specifications.href).to include("immersive-web/specifications")
      end
    end
  end

  describe "attributes" do
    it "has the correct attributes" do
      expect(group).to respond_to(:id)
      expect(group).to respond_to(:name)
      expect(group).to respond_to(:type)
      expect(group).to respond_to(:description)
      expect(group).to respond_to(:shortname)
      expect(group).to respond_to(:discr)
      expect(group).to respond_to(:links)
    end

    it "sets attributes correctly from hash" do
      expect(group.id).to eq("109735")
      expect(group.name).to eq("Immersive Web Working Group")
      expect(group.type).to eq("working group")
      expect(group.description).to eq("The Immersive Web Working Group aims to develop standards")
      expect(group.shortname).to eq("immersive-web")
      expect(group.discr).to eq("w3cgroup")
    end
  end

  describe "helper methods" do
    it "returns the correct links" do
      expect(group.links.self.href).to eq("https://api.w3.org/groups/109735")
      expect(group.links.homepage.href).to eq("https://www.w3.org/immersive-web/")
      expect(group.links.users.href).to eq("https://api.w3.org/groups/109735/users")
      expect(group.links.specifications.href).to eq("https://api.w3.org/groups/109735/specifications")
    end
  end

  xdescribe "client methods" do
    let(:client) { instance_double(W3cApi::Client) }
    let(:users) { [instance_double(W3cApi::Models::User)] }
    let(:specifications) { [instance_double(W3cApi::Models::Specification)] }
    let(:chairs) { [instance_double(W3cApi::Models::User)] }
    let(:team_contacts) { [instance_double(W3cApi::Models::User)] }

    it "fetches users using the client" do
      expect(client).to receive(:group_users).with("109735").and_return(users)
      expect(group.links.users.href).to eq(users.links.self.href)
    end

    it "fetches specifications using the client" do
      expect(client).to receive(:group_specifications).with("109735").and_return(specifications)
      expect(group.specifications(client)).to eq(specifications)
    end

    it "fetches chairs using the client" do
      expect(client).to receive(:group_chairs).with(109_735).and_return(chairs)
      expect(group.chairs(client)).to eq(chairs)
    end

    it "fetches team contacts using the client" do
      expect(client).to receive(:group_team_contacts).with(109_735).and_return(team_contacts)
      expect(group.team_contacts(client)).to eq(team_contacts)
    end

    it "returns nil when client is not provided" do
      expect(group.users).to be_nil
      expect(group.specifications).to be_nil
      expect(group.chairs).to be_nil
      expect(group.team_contacts).to be_nil
    end
  end

  describe "serialization" do
    it "can be converted to JSON" do
      json = group.to_json
      expect(json).to be_a(String)
      expect(json).to include('"id":"109735"')
      expect(json).to include('"name":"Immersive Web Working Group"')
    end

    it "can be converted to YAML" do
      yaml = group.to_yaml
      expect(yaml).to be_a(String)
      expect(yaml).to include("type: working group")
      expect(yaml).to include("name: Immersive Web Working Group")
    end
  end
end
