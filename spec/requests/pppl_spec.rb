# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "PPPL has a harvest endpoint", type: :request do
  let(:pppl1) { File.read(File.join(fixture_path, 'files', 'pppl1.json')) }
  let(:other_data) { File.read(File.join(fixture_path, 'files', 'bitklavier_binaural.json')) }
  let(:indexer) { DescribeIndexer.new }

  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    indexer.index_one(pppl1)
    indexer.index_one(other_data)
  end

  it "provides data needed for OSTI reporting" do
    get "/pppl.json"
    expect(response).to have_http_status(:success)
    results = JSON.parse(response.body)
    # There should be two records in the index, but only one of them is from PPPL
    expect(results.count).to eq 1
  end
end
