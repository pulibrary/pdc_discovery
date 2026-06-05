# frozen_string_literal: true
require "rails_helper"

RSpec.describe DraftWorksIndexer do
  describe 'indexing a single record' do
    let(:single_item) { file_fixture("pdc_describe_draft.json").read }
    let(:indexer) do
      described_class.new(rss_url: "file://whatever.rss")
    end
    let(:indexed_record) do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index_one(single_item)
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      response["response"]["docs"].first
    end

    context "basic fields" do
      ##
      # The id is based on the draft DOI
      # A doi of 10.80021/t4ef-kr07 will become doi-10-80021-t4ef-kr07
      it "id" do
        expect(indexed_record["id"]).to eq "doi-10-80021-t4ef-kr07"
      end
    end
  end
end
