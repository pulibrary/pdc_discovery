# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "PPPL has a harvest endpoint", type: :request do
  let(:pppl1) { File.read(File.join(fixture_path, 'files', 'pppl1.json')) }
  let(:pppl2) { File.read(File.join(fixture_path, 'files', 'pppl2.json')) }
  let(:pppl3) { File.read(File.join(fixture_path, 'files', 'pppl3.json')) }
  let(:pppl4) { File.read(File.join(fixture_path, 'files', 'pppl4.json')) }

  let(:other_data) { File.read(File.join(fixture_path, 'files', 'bitklavier_binaural.json')) }
  let(:indexer) { DescribeIndexer.new }

  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    indexer.index_one(pppl1)
    indexer.index_one(pppl2)
    indexer.index_one(other_data)
    indexer.index_one(pppl3)

    # Note that pppl2 should have the most recent timestamp, since it was indexed last
    indexer.index_one(pppl4)
  end

  # We provide the entire PDC Describe JSON record in the solr field pdc_describe_json_ss
  it "provides PDC Describe JSON records for OSTI reporting" do
    get "/pppl_reporting_feed.json"
    expect(response).to have_http_status(:success)
    results = JSON.parse(response.body)
    # There should be 5 records in the index, but only 4 of them are from PPPL
    expect(results.count).to eq 4
    # The most recently indexed item (pppl4) should be first
    first_doi_url = JSON.parse(results.first["pdc_describe_json_ss"])["resource"]["doi"]
    expect(first_doi_url).to match(JSON.parse(pppl4)["resource"]["doi"])
  end

  it "can paginate through multiple pages of responses" do
    get "/pppl_reporting_feed.json?per_page=2"
    results = JSON.parse(response.body)
byebug
    # The first item on the first page is pppl2 because it was indexed most recently
    first_doi_url = JSON.parse(results.first["pdc_describe_json_ss"])["resource"]["doi"]
    expect(first_doi_url).to match(JSON.parse(pppl2)["resource"]["doi"])

    # Because we set the per_page parameter to 2, we should see two results on the first page
    expect(results.count).to eq 2

    get "/pppl_reporting_feed.json?per_page=2&page=2"
    results = JSON.parse(response.body)

byebug
    # The first item on the second page is pppl3
    first_doi_url = JSON.parse(results.first["pdc_describe_json_ss"])["resource"]["doi"]
    expect(first_doi_url).to match(JSON.parse(pppl3)["resource"]["doi"])


  end
end
