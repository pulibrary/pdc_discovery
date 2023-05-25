# frozen_string_literal: true
require "./lib/traject/solr_cloud_helper.rb"

RSpec.describe SolrCloudHelper do
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
end
