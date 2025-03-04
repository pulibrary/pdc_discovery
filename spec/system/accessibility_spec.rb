# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :system, js: true do
  before do
    load_describe_small_data
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
      visit '/catalog/doi-10-34770-r75s-9j74'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa, :section508)
        .skipping(:'color-contrast') # false positives
        .excluding(".tt-hint") # Issue is in typeahead.js library
    end
  end
end
