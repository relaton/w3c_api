# frozen_string_literal: true

require "spec_helper"

RSpec.describe "W3cApi Pagination", :vcr do
  let(:client) { W3cApi::Client.new }

  describe "pagination parameters" do
    it "supports page and items parameters for specifications" do
      specs_page1 = client.specifications(page: 1, items: 5)

      expect(specs_page1.page).to eq(1)
      expect(specs_page1.limit).to eq(5)
      expect(specs_page1.links.specifications.length).to eq(5)
    end

    it "supports page and items parameters for groups" do
      groups_page1 = client.groups(page: 1, items: 3)

      expect(groups_page1.page).to eq(1)
      expect(groups_page1.limit).to eq(3)
      expect(groups_page1.links.groups.length).to eq(3)
    end

    it "supports page and items parameters for affiliations" do
      affiliations_page1 = client.affiliations(page: 1, items: 3)

      expect(affiliations_page1.page).to eq(1)
      expect(affiliations_page1.limit).to eq(3)
      expect(affiliations_page1.links.affiliations.length).to eq(3)
    end

    it "supports page and items parameters for series" do
      series_page1 = client.series(page: 1, items: 3)

      expect(series_page1.page).to eq(1)
      expect(series_page1.limit).to eq(3)
      expect(series_page1.links.series.length).to eq(3)
    end

    it "supports page and items parameters for translations" do
      translations_page1 = client.translations(page: 1, items: 3)

      expect(translations_page1.page).to eq(1)
      expect(translations_page1.limit).to eq(3)
      expect(translations_page1.links.translations.length).to eq(3)
    end

    it "supports page and items parameters for ecosystems" do
      ecosystems_page1 = client.ecosystems(page: 1, items: 3)

      expect(ecosystems_page1.page).to eq(1)
      expect(ecosystems_page1.limit).to eq(3)
      expect(ecosystems_page1.links.ecosystems.length).to eq(3)
    end
  end

  describe "next page functionality" do
    it "provides next link for specifications when more pages exist" do
      specs_page1 = client.specifications(page: 1, items: 5)

      expect(specs_page1.links).to respond_to(:next)
      expect(specs_page1.links.next).not_to be_nil

      next_page = specs_page1.links.next.realize
      expect(next_page.page).to eq(2)
      expect(next_page.limit).to eq(5)
      expect(next_page.links.specifications.length).to eq(5)

      # Verify different content
      expect(specs_page1.links.specifications.first.title).not_to eq(next_page.links.specifications.first.title)
    end

    it "provides navigation links (first, prev, next, last)" do
      specs_page1 = client.specifications(page: 1, items: 5)

      expect(specs_page1.links).to respond_to(:first)
      expect(specs_page1.links).to respond_to(:prev)
      expect(specs_page1.links).to respond_to(:next)
      expect(specs_page1.links).to respond_to(:last)
    end

    it "can navigate through multiple pages" do
      # Get first page
      page1 = client.specifications(page: 1, items: 3)
      expect(page1.page).to eq(1)

      # Get next page via link
      page2 = page1.links.next.realize
      expect(page2.page).to eq(2)

      # Get next page from page 2
      page3 = page2.links.next.realize
      expect(page3.page).to eq(3)

      # Verify all pages have different content
      titles = [
        page1.links.specifications.first.title,
        page2.links.specifications.first.title,
        page3.links.specifications.first.title,
      ]

      expect(titles.uniq.length).to eq(3) # All different
    end
  end

  describe "nested resource pagination" do
    it "supports pagination for group specifications" do
      specs = client.group_specifications(109_735, page: 1, items: 3)

      expect(specs.page).to eq(1)
      expect(specs.limit).to eq(3)
      expect(specs.links.specifications.length).to be <= 3
    end

    it "supports pagination for group users" do
      users = client.group_users(109_735, page: 1, items: 3)

      expect(users.page).to eq(1)
      expect(users.limit).to eq(3)
      expect(users.links.users.length).to be <= 3
    end

    it "supports pagination for affiliation participants" do
      participants = client.affiliation_participants(35_662, page: 1, items: 3)

      expect(participants.page).to eq(1)
      expect(participants.limit).to eq(3)
      expect(participants.links.participants.length).to be <= 3
    end
  end

  describe "default pagination behavior" do
    it "uses default pagination when no parameters provided" do
      specs = client.specifications

      expect(specs.page).to eq(1)
      expect(specs.limit).to eq(100) # Default limit
      expect(specs.links.specifications.length).to eq(100)
    end

    it "respects only items parameter when page not specified" do
      specs = client.specifications(items: 10)

      expect(specs.page).to eq(1)
      expect(specs.limit).to eq(10)
      expect(specs.links.specifications.length).to eq(10)
    end

    it "respects only page parameter when items not specified" do
      specs = client.specifications(page: 2)

      expect(specs.page).to eq(2)
      expect(specs.limit).to eq(100) # Default limit
      expect(specs.links.specifications.length).to eq(100)
    end
  end
end
