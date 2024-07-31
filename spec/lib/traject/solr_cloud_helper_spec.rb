# frozen_string_literal: true
require "./lib/traject/solr_cloud_helper.rb"

RSpec.describe SolrCloudHelper do
  let(:json_response) { { 'content-type' => 'application/json; charset=utf-8' } }
  let(:alias_uri) { URI::HTTP.build(schema: "http", host: "fake-solr", path: "/solr/pdc-discovery-staging") }
  let(:alias_unknown_uri) { URI::HTTP.build(schema: "http", host: "fake-solr", path: "/solr/alias-unknown") }
  let(:solr_collection_list) { file_fixture("solr_collection_list.json").read }
  let(:solr_aliases_1) { file_fixture("solr_aliases_1.json").read }
  let(:solr_aliases_2) { file_fixture("solr_aliases_2.json").read }

  before do
    stub_request(:get, "http://fake-solr/solr/admin/collections?action=LIST")
      .to_return(status: 200, body: solr_collection_list, headers: json_response)
  end

  describe "#collection_exist?" do
    it "finds collections" do
      expect(described_class.collection_exist?(alias_uri, "pdc-discovery-staging-1")).to be true
      expect(described_class.collection_exist?(alias_uri, "not-a-collection")).to be false
    end
  end

  describe "#collection_writer_commit!" do
    it "commits collection" do
      expect(described_class.collection_writer_commit!).to be_a(HTTParty::Response)
    end
  end

  describe "#current_collection_for_alias" do
    it "returns the collection for the alias" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      expect(described_class.current_collection_for_alias(alias_uri)).to eq "pdc-discovery-staging-1"
    end
    it "updates solr alias" do
      expect(described_class.update_solr_alias!).to eq true
    end
  end

  describe "#alternate_collection_for_alias" do
    it "returns alternate collection for the alias" do
      # when alias points to pdc-discovery-staging-1, alternate is pdc-discovery-staging-2
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      expect(described_class.alternate_collection_for_alias(alias_uri)).to eq "pdc-discovery-staging-2"

      # when alias points to pdc-discovery-staging-2, alternate is pdc-discovery-staging-1
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_2, headers: json_response)
      expect(described_class.alternate_collection_for_alias(alias_uri)).to eq "pdc-discovery-staging-1"

      # when alias is unknown return the alias (i.e. no alternate)
      expect(described_class.alternate_collection_for_alias(alias_unknown_uri)).to eq "alias-unknown"
    end
  end

  describe "#collection_writer_for_alias" do
    it "returns the alternate collection as the collection_writer" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      expect(described_class.collection_writer_for_alias(alias_uri, false)).to eq "http://fake-solr/solr/pdc-discovery-staging-2"
    end

    it "re-creates the alternate collection that will be used as the collection_writer" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=DELETE&name=pdc-discovery-staging-2")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=CREATE&collection.configName=pdc-discovery-test&name=pdc-discovery-staging-2&numShards=1&replicationFactor=3")
        .to_return(status: 200, body: '{"success":"true"}', headers: json_response)
      expect(described_class.collection_writer_for_alias(alias_uri, true)).to eq "http://fake-solr/solr/pdc-discovery-staging-2"
    end
  end

  describe "collection_reader_url" do
    it "defaults to the Solr used by Blacklight" do
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      expect(described_class.collection_reader_url + "/").to eq Blacklight.default_index.connection.uri.to_s
    end
  end

  describe "#update_solr_alias!" do
    it "makes the call to CREATEALIAS" do
      allow(described_class).to receive(:alias_uri).and_return(URI.parse("http://fake-solr/solr/pdc-discovery-staging"))
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=LISTALIASES")
        .to_return(status: 200, body: solr_aliases_1, headers: json_response)
      stub_request(:get, "http://fake-solr/solr/admin/collections?action=CREATEALIAS&collections=pdc-discovery-staging-2&name=pdc-discovery-staging")
        .to_return(status: 200, body: "", headers: json_response)
      expect(described_class.update_solr_alias!).to eq true
    end
  end
end
