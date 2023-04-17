# frozen_string_literal: true
require "./lib/traject/import_helper.rb"

RSpec.describe ImportHelper do
  let(:solr_aliases) { file_fixture("solr_aliases.json").read }
  let(:solr_collection_status) { file_fixture("solr_collection_status.json").read }

  before do
    stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
      .with(
         headers: {
           'Accept' => '*/*',
           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'User-Agent' => 'Ruby'
         }
       )
      .to_return(status: 200, body: solr_aliases, headers: { 'content-type' => 'application/json; charset=utf-8' })

    stub_request(:get, "http://fake-solr/solr/admin/collections?action=COLSTATUS&collection=pdc-discovery-production-1")
      .with(
       headers: {
         'Accept' => '*/*',
         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
         'User-Agent' => 'Ruby'
       }
     )
      .to_return(status: 200, body: solr_collection_status, headers: { 'content-type' => 'application/json; charset=utf-8' })
  end

  describe "#solr_collection_for_uri" do
    it "finds the right collection when the Solr URI is an alias" do
      alias_url = URI("http://fake-solr/solr/pdc-discovery-production")
      collection = described_class.solr_collection_for_uri(alias_url)
      expect(collection).to eq "pdc-discovery-production-3"
    end

    it "finds the right collection when the Solr URI is a collection" do
      collection_url = URI("http://fake-solr/solr/pdc-discovery-production-3")
      collection = described_class.solr_collection_for_uri(collection_url)
      expect(collection).to eq "pdc-discovery-production-3"
    end

    it "defaults to collection in the URL when no alias or collection is found" do
      collection_url = URI("http://fake-solr/solr/collection-in-url")
      collection = described_class.solr_collection_for_uri(collection_url)
      expect(collection).to eq "collection-in-url"
    end
  end

  describe "#solr_leader_for_uri" do
    it "finds the leader for a given collection" do
      collection_url = URI("http://fake-solr/solr/pdc-discovery-production-1")
      leader_url = described_class.solr_leader_for_uri(collection_url)
      expect(leader_url).to eq "http://lib-solr-prod6.princeton.edu:8983/solr/pdc-discovery-production-1/"
    end
  end
end
