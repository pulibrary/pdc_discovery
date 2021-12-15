# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe RecentlyAdded do
  before do
    stub_request(:get, "http://mysolr/solr/pdc-core-test/select?q=*:*&sort=issue_date_strict_ssi%20desc&wt=json").to_return(
      status: 200,
      body: file_fixture("recently_added.json"),
      headers: {
        'Content-Type' => 'application/json;charset=UTF-8',
        'Accept' => 'application/json',
        'User-Agent' => 'Faraday v1.0.1'
      }
    )
  end

  it "returns a payload of the ten most recent items with required fields" do
    allow(Blacklight).to receive(:default_configuration).and_return(Struct.new(:connection_config).new({ url: "http://mysolr/solr/pdc-core-test" }))
    feed = described_class.feed
    expect(feed.count).to eq 10
    expect(feed.first.title).to eq "Shakespeare and Company Project Dataset: Lending Library Members"
    expect(feed.first.authors_et_al).to eq "Kotin, Joshua et al."
    expect(feed.first.genre).to eq "Dataset"
    expect(feed.first.issued_date).to eq "July 2020"
  end
end
# rubocop:enable RSpec/ExampleLength
