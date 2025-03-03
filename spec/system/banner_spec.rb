# frozen_string_literal: true

require 'rails_helper'

describe 'Website banner', type: :system, js: true do
  before do
    load_describe_small_data
  end

  it "has the banner on the homepage" do
    visit '/'
    expect(page).to have_css '#banner'
  end

  it "has the banner on a static page" do
    visit '/about'
    expect(page).to have_css '#banner'
  end

  it "has the banner on the search results page" do
    visit '/?search_field=all_fields&q=test'
    expect(page).to have_css '#banner'
  end

  it "has the banner on a single record page" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    expect(page).to have_css '#banner'
  end

  it "renders html tags in the banner" do
    visit '/catalog/7doi-10-34770-r75s-9j74'
    expect(page).not_to have_content "<i>test</i>"
    expect(page.find("div#banner h1 i").text).to eq "test"
    expect(page).not_to have_content "<b>test</b>"
    expect(page.find("div#banner p b").text).to eq "test"
    expect(page).to have_link "message", href: "mailto:fake@princeton.edu"
  end

  it "does not render a banner when there are no values in the configuration for the environment" do
    Rails.env = "not-an-environment"
    visit '/'
    expect(page).not_to have_css '#banner'
    Rails.env = "test"
  end
end
