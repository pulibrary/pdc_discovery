# frozen_string_literal: true
require 'rails_helper'

describe 'Search Results PDC Page', type: :system, js: true do
  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    Rails.configuration.pdc_discovery.index_pdc_describe = true
    pdc_files = Dir.entries(Rails.root.join("spec", "fixtures", "files", "pdc_describe_data", ""))
                   .reject { |name| [".", "..", "works.rss"].include?(name) }
    pdc_files.each do |name|
      stub_request(:get, "https://datacommons.princeton.edu/describe/works/#{name}")
        .to_return(status: 200, body: File.open(Rails.root.join("spec/fixtures/files/pdc_describe_data/#{name}")).read, headers: {})
    end
    stub_request(:get, "http://pdc_test_data/works.rss")
      .to_return(status: 200, body: File.open(Rails.root.join("spec", "fixtures", "files", "pdc_describe_data", "works.rss")).read, headers: {})
    indexer = DescribeIndexer.new(rss_url: "http://pdc_test_data/works.rss")
    indexer.index
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
