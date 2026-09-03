# frozen_string_literal: true
require 'rails_helper'

describe 'Search Results PDC Page', type: :system, js: true do
  before do
    load_describe_dataset
  end

  it "renders expected fields" do
    visit '/?search_field=all_fields&q='
    click_on "Community"
    click_link "Princeton Plasma Physics Laboratory"
    expect(page).to have_content("Subcommunity")
    click_on("Subcommunity")
    expect(page).to have_content("Stellarators")
    expect(page).to have_content("more")
    click_link("more")
    expect(page).to have_content("System Studies")
    click_on("System Studies")
    expect(page).to have_content("Fusion Pilot Plant performance and the role of a Sustained High Power Density tokamak")
  end

  it "renders the year published range limit facet" do
    visit '/?search_field=all_fields&q='
    click_on "Year Published"
    expect(page).to have_css "form.range_limit_form"
    expect(page).to have_button "Apply limit"
    expect(page).to have_css "canvas.blacklight-range-limit-chart", wait: 10
    find("summary", text: "Range List").click
    expect(page).to have_content "2022"
  end

  it "filters results by year published range" do
    visit '/?range[year_available_itsi][begin]=2022&range[year_available_itsi][end]=2022'
    expect(page).to have_css("span.single[data-blrl-single='2022']")
    expect(page).to have_css(".document", minimum: 1)
    expect(page).to have_content("Issue Date:\n2022")
  end

  it "applies a year range from the facet form" do
    visit '/?search_field=all_fields&q='
    click_on "Year Published"
    fill_in "range[year_available_itsi][begin]", with: "2022"
    fill_in "range[year_available_itsi][end]", with: "2022"
    click_on "Apply limit"
    expect(page).to have_css("span.single[data-blrl-single='2022']")
  end

  it 'does not render Schema.org tags' do
    visit '/?search_field=all_fields&q='
    expect(page.html.include?('"@context": "http://schema.org",')).to be false
  end
end
