# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe RecentlyAdded do
  let(:item1) { file_fixture("pppl1.json").read }
  let(:item2) { file_fixture("pppl2.json").read }
  let(:item3) { file_fixture("pppl3.json").read }
  let(:indexer) do
    DescribeIndexer.new(rss_url: "file://whatever.rss")
  end
  let(:indexed_record) do
    response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
    response["response"]["docs"].first
  end
  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index_one(item1)
    indexer.index_one(item2)
    indexer.index_one(item3)
  end

  it "returns a payload of the most recent items with required fields" do
    feed = described_class.feed
    expect(feed.count).to eq 3
    expect(feed.first.title).to eq "Lower Hybrid Drift Waves During Guide Field Reconnection"
    expect(feed.first.authors_et_al).to eq "Yoo, Jongsoo et al."
    expect(feed.first.genre).to eq "Dataset"
    expect(feed.first.issued_date).to eq "2020"
  end
end
# rubocop:enable RSpec/ExampleLength
