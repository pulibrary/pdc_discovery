# frozen_string_literal: true
require "./lib/traject/solr_cloud_helper.rb"

RSpec.describe SolrCloudHelper do
  let(:alias_uri) { URI::HTTP.build(schema: "http", host: "fake-solr", path: "/solr/pdc-discovery-staging") }
  let(:solr_collection_list) { file_fixture("solr_collection_list.json").read }
  let(:solr_aliases) { file_fixture("solr_aliases.json").read }

  describe "#collection_exist?" do
    it "finds collections" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LIST")
        .to_return(status: 200, body: solr_collection_list, headers: { 'content-type' => 'application/json; charset=utf-8' })
      expect(described_class.collection_exist?(alias_uri, "pdc-discovery-staging-1")).to be true
      expect(described_class.collection_exist?(alias_uri, "not-a-collection")).to be false
    end
  end

  describe "#current_collection_for_alias" do
    it "returns the collection for the alias" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases, headers: { 'content-type' => 'application/json; charset=utf-8' })
      expect(described_class.current_collection_for_alias(alias_uri)).to eq "pdc-discovery-staging-1"
    end
  end

  describe "#alternate_collection_for_alias" do
    it "returns alternate collection for the alias" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases, headers: { 'content-type' => 'application/json; charset=utf-8' })
      expect(described_class.alternate_collection_for_alias(alias_uri)).to eq "pdc-discovery-staging-2"
    end
  end
end
