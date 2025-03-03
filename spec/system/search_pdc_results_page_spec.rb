# frozen_string_literal: true
require 'rails_helper'

describe 'Search Results PDC Page', type: :system, js: true do
  before do
    load_describe_dataset
    page.driver.browser.manage.window.resize_to(4000, 4000)
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

    click_on "Year Published"
    expect(page).to have_content "View larger"
    expect(page).not_to have_content "[Missing]"
    click_on "View larger"
    expect(page).to have_content "2022\n2022"
  end

  it 'does not render Schema.org tags' do
    visit '/?search_field=all_fields&q='
    expect(page.html.include?('"@context": "http://schema.org",')).to be false
  end
end
