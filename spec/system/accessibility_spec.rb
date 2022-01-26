# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :system, js: true do

  let(:community_fetch_with_expanded_metadata) { file_fixture("single_item.xml").read }
  let(:indexer) do
    Indexer.new(community_fetch_with_expanded_metadata)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
    stub_request(:get, "https://github.com/mozilla/geckodriver/releases/latest")
    .with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'github.com',
        'User-Agent'=>'Ruby'
      }
    )
  end
  context "homepage" do
    it "complies with WCAG 2.0 AA and Section 508" do
      visit "/"
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508)
        .skipping(:'color-contrast') # false positives
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end

  context "about page" do
    it "complies with WCAG 2.0 AA and Section 508" do
      visit "/about"
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508)
        .skipping(:'color-contrast') # false positives
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end

  context "search results page" do
    it "complies with WCAG 2.0 AA and Section 508" do
      visit '/?search_field=all_fields&q='
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508)
        .skipping(:'color-contrast') # false positives
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end

  context "single record page page" do
    it "complies with WCAG 2.0 AA and Section 508" do
      visit '/catalog/78348'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508)
        .skipping(:'color-contrast') # false positives
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end
end
