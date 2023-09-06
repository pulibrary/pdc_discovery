# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Catalog", type: :request do

  context "when indexing from DSpace" do
    let(:dspace_fixtures) { File.read(File.join(fixture_path, 'spherical_torus.xml')) }
    let(:indexer) do
      DspaceIndexer.new(dspace_fixtures)
    end
    before do
      indexer.index
    end

    it 'discards search tracking parameters' do
      get "/catalog/84912/track?counter=1&document_id=84912"
      expect(response).to redirect_to("/catalog/84912")
    end

    describe "GET /doi/:doi" do
      let(:doi) { "doi:10.1088/0029-5515/57/1/016034" }
      let(:document_id) { "84912" }

      it "retrieves Solr Documents using a given DOI" do
        get "/doi/#{doi}"
        expect(response).to redirect_to(solr_document_path(id: document_id))
      end

      context "when passing only a segment of the DOI" do
        let(:doi) { "10.1088/0029-5515/57/1/016034" }

        it "retrieves Solr Documents using a given DOI" do
          get "/doi/#{doi}"
          expect(response).to redirect_to(solr_document_path(id: document_id))
        end
      end
    end

    describe "GET /ark/:ark" do
      let(:ark) { "http://arks.princeton.edu/ark:/88435/dsp01kd17cw34n" }
      let(:document_id) { "84912" }
      it "retrieves Solr Documents using a given ARK" do
        get "/ark/#{ark}"
        expect(response).to redirect_to(solr_document_path(id: document_id))
      end

      context "when passing only a segment of the ARK" do
        let(:ark) { "88435/dsp01kd17cw34n" }

        it "retrieves Solr Documents using a given ARK" do
          get "/ark/#{ark}"
          expect(response).to redirect_to(solr_document_path(id: document_id))
        end
      end
    end
  end

  context "when indexing from PDC Describe" do
    context "when two DOI values are present" do
      let(:resource1) { file_fixture("sowing_the_seeds.json").read }
      let(:bitklavier_binaural_json) { file_fixture("bitklavier_binaural.json").read }
      let(:bitklavier_binaural) do
        response_body = bitklavier_binaural_json
        json_response = JSON.parse(response_body)
        json_resource = json_response["resource"]
        json_titles = json_resource["titles"]
        json_title = json_titles.first
        json_title["title"] = "test title"
        json_response.to_json
      end
      let(:doi) { "10.34770/r75s-9j74" }
      let(:document_id) { "doi-10-34770-r75s-9j74" }
      let(:rss_feed) { file_fixture("works.rss").read }
      let(:rss_url_string) { "https://pdc-describe-prod.princeton.edu/describe/works.rss" }
      let(:indexer) { DescribeIndexer.new(rss_url: rss_url_string) }

      before do
        Blacklight.default_index.connection.delete_by_query("*:*")
        Blacklight.default_index.connection.commit
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works.rss")
          .to_return(status: 200, body: rss_feed)
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/6.json")
          .to_return(status: 200, body: resource1, headers: {})
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/20.json")
          .to_return(status: 200, body: bitklavier_binaural, headers: {})

        indexer.index
      end

      it "defaults to the Solr Documents with 'pdc_describe' within the 'data_source' field" do
        get "/doi/#{doi}"
        expect(response).to redirect_to(solr_document_path(id: document_id))
        follow_redirect!
        expect(response.body).to include("test title")
      end
    end
  end
end
