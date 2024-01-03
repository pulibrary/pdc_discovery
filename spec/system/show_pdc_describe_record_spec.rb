# frozen_string_literal: true

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
    page.driver.browser.manage.window.resize_to(4000, 4000)
  end

  it "renders total file size" do
    visit '/catalog/doi-10-34770-bm4s-t361'
    expect(page).to have_content("Total Size")
    expect(page).to have_content("373 MB")
  end
end
