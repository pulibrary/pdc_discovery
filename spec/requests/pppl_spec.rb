# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "PPPL has a harvest endpoint", type: :request do
  let(:pppl1) { File.read(File.join(fixture_paths.first, 'files', 'pppl1.json')) }
  let(:pppl2) { File.read(File.join(fixture_paths.first, 'files', 'pppl2.json')) }
  let(:pppl3) { File.read(File.join(fixture_paths.first, 'files', 'pppl3.json')) }
  let(:pppl4) { File.read(File.join(fixture_paths.first, 'files', 'pppl4.json')) }

  let(:other_data) { File.read(File.join(fixture_paths.first, 'files', 'bitklavier_binaural.json')) }
  let(:indexer) { DescribeIndexer.new }

  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    indexer.index_one(pppl1)
    indexer.index_one(pppl2)
    indexer.index_one(other_data)
    indexer.index_one(pppl3)

    # Note that pppl4 should have the most recent timestamp, since it was indexed last
    indexer.index_one(pppl4)
  end

  # We provide the entire PDC Describe JSON record in the solr field pdc_describe_json_ss
  it "provides PDC Describe JSON records for OSTI reporting" do
    get "/pppl_reporting_feed.json"
    expect(response).to have_http_status(:success)
    results = JSON.parse(response.body)

    # There should be 5 records in the index, but only 4 of them are from PPPL
    expect(results.count).to eq 4
    result = results.first
    expect(result).to include("pdc_describe_json_ss")
    json_result = JSON.parse(result["pdc_describe_json_ss"])
    expect(json_result).to include("resource")
    json_resource = json_result["resource"]
    expect(json_resource).to include("doi")
    doi = json_resource["doi"]

    pppl1_json = JSON.parse(pppl1)
    # The most recently indexed item (pppl1) should be first
    expect(doi).to match(pppl1_json["resource"]["doi"])
  end

  context "when requesting 2 items per page" do
    before do
      get "/pppl_reporting_feed.json?per_page=2"
    end

    it "can paginate through multiple pages of responses" do
      results = JSON.parse(response.body)
      result = results.first

      # Because we set the per_page parameter to 2, we should see two results on the first page
      expect(results.count).to eq 2
      json_result = JSON.parse(result["pdc_describe_json_ss"])
      json_resource = json_result["resource"]
      doi = json_resource["doi"]
      pppl1_json = JSON.parse(pppl1)

      # The first item on the first page is pppl2 because it was indexed most recently
      expect(doi).to match(pppl1_json["resource"]["doi"])

      get "/pppl_reporting_feed.json?per_page=2&page=2"
      expect(results.count).to eq 2

      # The first item on the second page should be pppl2
      expect(result).to include("pdc_describe_json_ss")
      expect(json_result).to include("resource")
      expect(json_resource).to include("doi")

      expect(doi).to match(pppl1_json["resource"]["doi"])
    end

    context "when requesting a specific page of results" do
      before do
        get "/pppl_reporting_feed.json?per_page=3&page=2"
      end

      it "can paginate through multiple pages of responses" do
        results = JSON.parse(response.body)
        result = results.first

        json_result = JSON.parse(result["pdc_describe_json_ss"])
        json_resource = json_result["resource"]
        doi = json_resource["doi"]
        pppl4_json = JSON.parse(pppl4)

        expect(results.count).to eq 1

        # The first item on the second page should be pppl2
        expect(result).to include("pdc_describe_json_ss")
        expect(json_result).to include("resource")
        expect(json_resource).to include("doi")

        expect(doi).to match(pppl4_json["resource"]["doi"])
      end
    end
  end
end
