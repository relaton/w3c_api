# frozen_string_literal: true

require "spec_helper"
require "stringio"

RSpec.describe W3cApi::Cli do
  let(:thor_command) { described_class.new }

  describe "specification commands" do
    let(:spec_command) { W3cApi::Commands::Specification.new }
    let(:client) { instance_double(W3cApi::Client) }
    let(:specification) { instance_double(W3cApi::Models::Specification) }
    let(:specifications) { instance_double(W3cApi::Models::SpecificationIndex) }
    let(:versions) { instance_double(W3cApi::Models::SpecVersionIndex) }

    before do
      allow(W3cApi::Client).to receive(:new).and_return(client)
      allow(specification).to receive(:to_yaml).and_return("---\nshortname: html5\ntitle: HTML5\n")
      allow(specification).to receive(:to_json).and_return('{"shortname":"html5","title":"HTML5"}')
      allow(specifications).to receive(:to_yaml).and_return("---\n- shortname: html5\n  title: HTML5\n")
      allow(specifications).to receive(:to_json).and_return('[{"shortname":"html5","title":"HTML5"}]')
      allow(versions).to receive(:to_yaml).and_return("---\n- date: 2017-12-14\n  title: REC\n")
      allow(versions).to receive(:to_json).and_return('[{"date":"2017-12-14","title":"REC"}]')
    end

    describe "#fetch" do
      before do
        # Stub STDOUT to capture output
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs specifications in the correct format" do
        expect(client).to receive(:specifications).and_return(specifications)
        allow(spec_command).to receive(:client).and_return(client)

        # Execute the command with captured output
        expect { spec_command.fetch }.not_to raise_error
        expect($stdout.string).to include('"shortname":"html5"')
      end

      it "outputs a single specification when shortname is provided" do
        expect(client).to receive(:specification).with("html5").and_return(specification)
        allow(spec_command).to receive(:client).and_return(client)

        expect do
          spec_command.invoke(:fetch, [], { shortname: "html5" })
        end.not_to raise_error
        expect($stdout.string).to include("shortname: html5")
      end

      it "outputs specification as JSON with --format=json" do
        expect(client).to receive(:specifications).and_return(specifications)
        allow(spec_command).to receive(:client).and_return(client)

        expect do
          spec_command.invoke(:fetch, [], { format: "json" })
        end.not_to raise_error
        expect($stdout.string).to include('"shortname":"html5"')
      end

      it "outputs specifications by status when status is provided" do
        expect(client).to receive(:specifications_by_status).with("Recommendation").and_return(specifications)
        allow(spec_command).to receive(:client).and_return(client)

        expect do
          spec_command.invoke(:fetch, [],
                              { status: "Recommendation" })
        end.not_to raise_error
        expect($stdout.string).to include("shortname: html5")
      end
    end

    describe "#versions" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs versions of a specification" do
        expect(client).to receive(:specification_versions).with("html5").and_return(versions)
        allow(spec_command).to receive(:client).and_return(client)

        expect do
          spec_command.invoke(:versions, [], { shortname: "html5" })
        end.not_to raise_error
        expect($stdout.string).to include("date: 2017-12-14")
      end
    end
  end

  describe "group commands" do
    let(:group_command) { W3cApi::Commands::Group.new }
    let(:client) { instance_double(W3cApi::Client) }
    let(:group) { instance_double(W3cApi::Models::Group) }
    let(:groups) { instance_double(W3cApi::Models::GroupIndex) }
    let(:users) { instance_double(W3cApi::Models::UserIndex) }
    let(:specifications) { instance_double(W3cApi::Models::SpecificationIndex) }

    before do
      allow(W3cApi::Client).to receive(:new).and_return(client)
      allow(group).to receive(:to_yaml).and_return("---\nid: 109735\nname: Immersive Web Working Group\n")
      allow(group).to receive(:to_json).and_return('{"id":109735,"name":"Immersive Web Working Group"}')
      allow(groups).to receive(:to_yaml).and_return("---\n- id: 109735\n  name: Immersive Web Working Group\n")
      allow(groups).to receive(:to_json).and_return('[{"id":109735,"name":"Immersive Web Working Group"}]')
      allow(users).to receive(:to_yaml).and_return("---\n- id: 123\n  name: John Doe\n")
      allow(users).to receive(:to_json).and_return('[{"id":123,"name":"John Doe"}]')
      allow(specifications).to receive(:to_yaml).and_return("---\n- shortname: webxr\n  title: WebXR\n")
      allow(specifications).to receive(:to_json).and_return('[{"shortname":"webxr","title":"WebXR"}]')
    end

    describe "#fetch" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs groups in the correct format" do
        expect(client).to receive(:groups).and_return(groups)
        allow(group_command).to receive(:client).and_return(client)

        # Execute the command with captured output
        expect { group_command.fetch }.not_to raise_error
        expect($stdout.string).to include('"name":"Immersive Web Working Group"')
      end

      it "outputs a single group when id is provided" do
        expect(client).to receive(:group).with(109_735).and_return(group)
        allow(group_command).to receive(:client).and_return(client)

        expect do
          group_command.invoke(:fetch, [], { id: 109_735 })
        end.not_to raise_error
        expect($stdout.string).to include("name: Immersive Web Working Group")
      end

      it "outputs group as JSON with --format=json" do
        expect(client).to receive(:groups).and_return(groups)
        allow(group_command).to receive(:client).and_return(client)

        expect do
          group_command.invoke(:fetch, [], { format: "json" })
        end.not_to raise_error
        expect($stdout.string).to include('"name":"Immersive Web Working Group"')
      end
    end

    describe "#users" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs users of a group" do
        expect(client).to receive(:group_users).with(109_735).and_return(users)
        allow(group_command).to receive(:client).and_return(client)

        expect do
          group_command.invoke(:users, [], { id: 109_735 })
        end.not_to raise_error
        expect($stdout.string).to include("name: John Doe")
      end
    end

    describe "#specifications" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs specifications of a group" do
        expect(client).to receive(:group_specifications).with(109_735).and_return(specifications)
        allow(group_command).to receive(:client).and_return(client)

        expect do
          group_command.invoke(:specifications, [], { id: 109_735 })
        end.not_to raise_error
        expect($stdout.string).to include("title: WebXR")
      end
    end
  end

  describe "user commands" do
    let(:user_command) { W3cApi::Commands::User.new }
    let(:client) { instance_double(W3cApi::Client) }
    let(:user) { instance_double(W3cApi::Models::User) }
    let(:groups) { instance_double(W3cApi::Models::GroupIndex) }
    let(:specifications) { instance_double(W3cApi::Models::SpecificationIndex) }
    let(:affiliations) { instance_double(W3cApi::Models::AffiliationIndex) }

    before do
      allow(W3cApi::Client).to receive(:new).and_return(client)
      allow(user).to receive(:to_yaml).and_return("---\nid: f1ovb5rydm8s0go04oco0cgk0sow44w\nname: Jennifer Strickland\n")
      allow(user).to receive(:to_json).and_return('{"id":"f1ovb5rydm8s0go04oco0cgk0sow44w","name":"Jennifer Strickland"}')
      allow(groups).to receive(:to_yaml).and_return("---\n- id: 109735\n  name: Immersive Web Working Group\n")
      allow(groups).to receive(:to_json).and_return('[{"id":109735,"name":"Immersive Web Working Group"}]')
      allow(specifications).to receive(:to_yaml).and_return("---\n- shortname: webxr\n  title: WebXR\n")
      allow(specifications).to receive(:to_json).and_return('[{"shortname":"webxr","title":"WebXR"}]')
      allow(affiliations).to receive(:to_yaml).and_return("---\n- id: 1092\n  name: MITRE Corporation\n")
      allow(affiliations).to receive(:to_json).and_return('[{"id":1092,"name":"MITRE Corporation"}]')
    end

    describe "#fetch" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs a user when id is provided" do
        expect(client).to receive(:user).with("f1ovb5rydm8s0go04oco0cgk0sow44w").and_return(user)
        allow(user_command).to receive(:client).and_return(client)

        expect do
          user_command.invoke(:fetch, [],
                              { id: "f1ovb5rydm8s0go04oco0cgk0sow44w" })
        end.not_to raise_error
        expect($stdout.string).to include("name: Jennifer Strickland")
      end

      it "outputs user as JSON with --format=json" do
        expect(client).to receive(:user).with("f1ovb5rydm8s0go04oco0cgk0sow44w").and_return(user)
        allow(user_command).to receive(:client).and_return(client)

        expect do
          user_command.invoke(:fetch, [],
                              { id: "f1ovb5rydm8s0go04oco0cgk0sow44w", format: "json" })
        end.not_to raise_error
        expect($stdout.string).to include('"name":"Jennifer Strickland"')
      end
    end

    describe "#groups" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs groups a user is a member of" do
        expect(client).to receive(:user_groups).with("f1ovb5rydm8s0go04oco0cgk0sow44w").and_return(groups)
        allow(user_command).to receive(:client).and_return(client)

        expect do
          user_command.invoke(:groups, [],
                              { id: "f1ovb5rydm8s0go04oco0cgk0sow44w" })
        end.not_to raise_error
        expect($stdout.string).to include("name: Immersive Web Working Group")
      end
    end

    describe "#specifications" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs specifications a user has contributed to" do
        expect(client).to receive(:user_specifications).with("f1ovb5rydm8s0go04oco0cgk0sow44w").and_return(specifications)
        allow(user_command).to receive(:client).and_return(client)

        expect do
          user_command.invoke(:specifications, [],
                              { id: "f1ovb5rydm8s0go04oco0cgk0sow44w" })
        end.not_to raise_error
        expect($stdout.string).to include("title: WebXR")
      end
    end
  end

  describe "translation commands" do
    let(:translation_command) { W3cApi::Commands::Translation.new }
    let(:client) { instance_double(W3cApi::Client) }
    let(:translation) { instance_double(W3cApi::Models::Translation) }
    let(:translations) { instance_double(W3cApi::Models::TranslationIndex) }

    before do
      allow(W3cApi::Client).to receive(:new).and_return(client)
      allow(translation).to receive(:to_yaml).and_return("---\nid: 2\ntitle: Video Introduction in French\nlanguage: fr\n")
      allow(translation).to receive(:to_json).and_return('{"id":2,"title":"Video Introduction in French","language":"fr"}')
      allow(translations).to receive(:to_yaml).and_return("---\n- id: 2\n  title: Video Introduction in French\n")
      allow(translations).to receive(:to_json).and_return('[{"id":2,"title":"Video Introduction in French"}]')
    end

    describe "#fetch" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs translations in the correct format" do
        expect(client).to receive(:translations).and_return(translations)
        allow(translation_command).to receive(:client).and_return(client)

        # Execute the command with captured output
        expect { translation_command.fetch }.not_to raise_error
        expect($stdout.string).to include('"title":"Video Introduction in French"')
      end

      it "outputs a single translation when id is provided" do
        expect(client).to receive(:translation).with(2).and_return(translation)
        allow(translation_command).to receive(:client).and_return(client)

        expect do
          translation_command.invoke(:fetch, [], { id: 2 })
        end.not_to raise_error
        expect($stdout.string).to include("language: fr")
      end
    end
  end

  describe "ecosystem commands" do
    let(:ecosystem_command) { W3cApi::Commands::Ecosystem.new }
    let(:client) { instance_double(W3cApi::Client) }
    let(:ecosystem) { instance_double(W3cApi::Models::Ecosystem) }
    let(:ecosystems) { instance_double(W3cApi::Models::EcosystemIndex) }
    let(:groups) { instance_double(W3cApi::Models::GroupIndex) }

    before do
      allow(W3cApi::Client).to receive(:new).and_return(client)
      allow(ecosystem).to receive(:to_yaml).and_return("---\nshortname: data\nname: Data and knowledge\n")
      allow(ecosystem).to receive(:to_json).and_return('{"shortname":"data","name":"Data and knowledge"}')
      allow(ecosystems).to receive(:to_yaml).and_return("---\n- shortname: data\n  name: Data and knowledge\n")
      allow(ecosystems).to receive(:to_json).and_return('[{"shortname":"data","name":"Data and knowledge"}]')
      allow(groups).to receive(:to_yaml).and_return("---\n- id: 109736\n  name: Data Shapes Working Group\n")
      allow(groups).to receive(:to_json).and_return('[{"id":109736,"name":"Data Shapes Working Group"}]')
    end

    describe "#fetch" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs ecosystems in the correct format" do
        expect(client).to receive(:ecosystems).and_return(ecosystems)
        allow(ecosystem_command).to receive(:client).and_return(client)

        # Execute the command with captured output
        expect { ecosystem_command.fetch }.not_to raise_error
        expect($stdout.string).to include('"name":"Data and knowledge"')
      end

      it "outputs a single ecosystem when shortname is provided" do
        expect(client).to receive(:ecosystem).with("data").and_return(ecosystem)
        allow(ecosystem_command).to receive(:client).and_return(client)

        expect do
          ecosystem_command.invoke(:fetch, [],
                                   { shortname: "data" })
        end.not_to raise_error
        expect($stdout.string).to include("name: Data and knowledge")
      end
    end

    describe "#groups" do
      before do
        @original_stdout = $stdout
        $stdout = StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it "outputs groups in an ecosystem" do
        expect(client).to receive(:ecosystem_groups).with("data").and_return(groups)
        allow(ecosystem_command).to receive(:client).and_return(client)

        expect do
          ecosystem_command.invoke(:groups, [],
                                   { shortname: "data" })
        end.not_to raise_error
        expect($stdout.string).to include("name: Data Shapes Working Group")
      end
    end
  end
end
