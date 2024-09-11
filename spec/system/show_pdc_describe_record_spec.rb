# frozen_string_literal: true
require 'rails_helper'

describe 'Show PDC Page', type: :system, js: true do
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
  end

  it "renders total file size" do
    visit '/catalog/doi-10-34770-bm4s-t361'
    expect(page).to have_content("Total Size")
    expect(page).to have_content("391 MB")
  end
  it "renders rights statement" do
    visit '/catalog/doi-10-34770-bm4s-t361'
    expect(page).to have_content("Creative Commons Attribution 4.0 International (CC BY)")
    expect(page).to have_link('CC BY', href: 'https://creativecommons.org/licenses/by/4.0/')
  end
  it 'has the README files first' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    expect(first_filename_spot).to eq("Fig11b_readme.hdf")
  end

  it "reports sizes using MB and KB" do
    visit '/catalog/doi-10-34770-bm4s-t361'
    # These tests are to validate our monkey-patched number_to_human_size (see number_to_human_size_converter.rb)
    # is dividing the size by 1000 instead of using the Rails default of 1024.
    file_size = find(:css, '#files-table>tbody>tr:first-child>td:nth-child(3)', match: :first).text
    expect(file_size).to eq("22 KB")
    file_size = find(:css, '#files-table>tbody>tr:nth-child(6)>td:nth-child(3)', match: :first).text
    expect(file_size).to eq("32.7 MB")
  end

  it 'sorts files by name initially' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    third_filename_spot = find(:xpath, "//table[@id='files-table']/tbody/tr[3]/td[1]").text
    expect(third_filename_spot).to eq("Fig10a.hdf")
  end
  it 'correctly sorts by file size' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    expect(first_filename_spot).to eq("Fig11b_readme.hdf")
    find(:xpath, "//thead/tr/th[3]").click
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    # "readme.txt" is the smallest file and so now it is first
    expect(first_filename_spot).to eq("readme.txt")
  end

  context "when crawler visits the site" do
    before do
      allow_any_instance_of(CatalogController).to receive(:agent_is_crawler?).and_return(true)
    end
    it 'does not display links when there is a crawler' do
      visit '/catalog/doi-10-34770-bm4s-t361'
      expect(page).to_not have_link(href: 'https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/Fig11b_readme.hdf')
    end
  end
end
