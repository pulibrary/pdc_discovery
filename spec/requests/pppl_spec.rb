# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "PPPL has a harvest endpoint", type: :request do
  let(:pppl1) { File.read(File.join(fixture_path, 'files', 'pppl1.json')) }
  let(:pppl2) { File.read(File.join(fixture_path, 'files', 'pppl2.json')) }
  let(:other_data) { File.read(File.join(fixture_path, 'files', 'bitklavier_binaural.json')) }
  let(:indexer) { DescribeIndexer.new }

  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    indexer.index_one(pppl1)
    indexer.index_one(other_data)
    # Note that pppl2 should have the most recent timestamp, since it was indexed last
    indexer.index_one(pppl2)
  end

  # This was the first pass at a PPPL harvesting endpoint.
  # I'm leaving it in place for now, but we should remove it if Chun decides
  # he prefers the second endpoint better. --Bess 29 March 2023
  it "provides data needed for OSTI reporting" do
    get "/pppl.json"
    expect(response).to have_http_status(:success)
    results = JSON.parse(response.body)
    # There should be 3 records in the index, but only 2 of them are from PPPL
    expect(results.count).to eq 2
    # The most recently indexed item (pppl2) should be first
    first_doi_url = results.first["uri_ssim"].first
    expect(first_doi_url).to match(JSON.parse(pppl2)["resource"]["doi"])
    # The data feed should include funders
    expect(results.first.keys).to include("funders_ss")
  end

  # This is the second try at a PPPL harvesting endpoint.
  # Instead of providing solr fields, we provide the entire PDC Describe JSON record.
  it "provides PDC Describe JSON records for OSTI reporting" do
    get "/pppl_reporting_feed.json"
    expect(response).to have_http_status(:success)
    results = JSON.parse(response.body)
    # There should be 3 records in the index, but only 2 of them are from PPPL
    expect(results.count).to eq 2
    # The most recently indexed item (pppl2) should be first
    first_doi_url = JSON.parse(results.first["pdc_describe_json_ss"])["resource"]["doi"]
    expect(first_doi_url).to match(JSON.parse(pppl2)["resource"]["doi"])
  end
end
