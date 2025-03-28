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
    sleep(0.1) # wait for the files to load via AJAX
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    expect(first_filename_spot).to eq("Fig11b_readme.hdf")
  end

  it "reports sizes using MB and KB" do
    visit '/catalog/doi-10-34770-bm4s-t361'
    sleep(0.1) # wait for the files to load via AJAX
    # These tests are to validate our monkey-patched number_to_human_size (see number_to_human_size_converter.rb)
    # is dividing the size by 1000 instead of using the Rails default of 1024.
    file_size = find(:css, '#files-table>tbody>tr:first-child>td:nth-child(2)', match: :first).text
    expect(file_size).to eq("22 KB")
    file_size = find(:css, '#files-table>tbody>tr:nth-child(6)>td:nth-child(2)', match: :first).text
    expect(file_size).to eq("32.7 MB")
  end

  it 'sorts files by name initially' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    third_filename_spot = find(:xpath, "//table[@id='files-table']/tbody/tr[3]/td[1]").text
    expect(third_filename_spot).to eq("Fig10a.hdf")
  end

  it 'shows file types when there is more than 10 in sidebar' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    # initially only first ten file types are shown
    expect(page).to have_content("Show More")
    expect(page).to have_selector('#document-file-type-list-toggle', visible: true)
    inital_file_types = find(:xpath, "//*[@id='document-file-type-list']/div/span[2]").text
    expect(inital_file_types).to eq("hdf(12), ccc(1), bbb(1), aaa(1), pdf(1), py(1), rb(1), xls(1), doc(1), tiff(1)")
    expect(page).to have_selector('#document-file-type-list-extra', visible: false)
    # clicks the Show More button to show the rest of the file types
    find(:xpath, "//*[@id='document-file-type-list-toggle']/span").click
    expect(page).to have_content("Show Less")
    expect(inital_file_types).to eq("hdf(12), ccc(1), bbb(1), aaa(1), pdf(1), py(1), rb(1), xls(1), doc(1), tiff(1)")
    rest_of_file_types = find(:xpath, "//*[@id='document-file-type-list-extra']/div/span[2]").text
    expect(rest_of_file_types).to eq("jpg(1), txt(1)")
    expect(page).to have_selector('#document-file-type-list-extra', visible: true)
    # Clicks the Show Less button to hide the rest of the file types
    find(:xpath, "//*[@id='document-file-type-list-toggle']/span").click
    expect(page).to have_content("Show More")
    expect(inital_file_types).to eq("hdf(12), ccc(1), bbb(1), aaa(1), pdf(1), py(1), rb(1), xls(1), doc(1), tiff(1)")
    expect(page).to have_selector('#document-file-type-list-extra', visible: false)
  end

  it 'shows version on sidebar when there is a version' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    version_header = '<span class="sidebar-header">Version</span>'
    expect(page.html.include?(version_header)).to be true
    version_number = '<span class="sidebar-value">1</span>'
    expect(page.html.include?(version_number)).to be true
  end

  it 'does not show version on sidebar when there is not a version' do
    visit '/catalog/doi-10-34770-9425-b553'
    version_header = '<span class="sidebar-header">Version</span>'
    expect(page.html.include?(version_header)).to be false
    version_number = '<span class="sidebar-value">1</span>'
    expect(page.html.include?(version_number)).to be false
  end

  it 'correctly sorts by file size' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    sleep(0.1) # wait for the files to load via AJAX
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    expect(first_filename_spot).to eq("Fig11b_readme.hdf")
    find(:xpath, "//thead/tr/th[2]").click # sort by file size
    first_filename_spot = find(:css, '#files-table>tbody>tr:first-child>td', match: :first).text
    # "readme.txt" is the smallest file and so now it is first
    expect(first_filename_spot).to eq("readme.txt")
  end

  it 'renders Schema.org tags' do
    visit '/catalog/doi-10-34770-bm4s-t361'
    expect(page.html.include?('"@context": "http://schema.org",')).to be true
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

  context "clicks on Find other works by this author" do
    it "uses link with lowercase orcid" do
      visit '/catalog/doi-10-34770-bm4s-t361'
      find('a', text: 'Bertelli, Nicola').click
      expect(page).to have_content("Find other works by this author in PDC Discovery.")
      expect(page).to have_link(href: '/?&q=0000-0002-9326-7585&search_field=orcid')
    end
  end
end
