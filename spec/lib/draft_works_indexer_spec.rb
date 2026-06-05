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
  end
end
