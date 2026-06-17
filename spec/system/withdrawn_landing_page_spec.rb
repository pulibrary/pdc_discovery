# frozen_string_literal: true
require 'rails_helper'

describe 'Landing page for withdrawn works', type: :system, js: true do
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
    indexer = WorksIndexer.new(rss_url: "http://pdc_test_data/works.rss")
    indexer.index
  end

  before do
    load_describe_dataset
  end

  it "renders withdrawn works landing page" do
    # This DOI (10.80021/bsdz-he25) is of a Work that has been withdrawn
    visit '/catalog/doi-10-80021-bsdz-he25'
    byebug
    expect(page).to have_content "Publication Withdrawn"
  end
end
