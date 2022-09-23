# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Catalog", type: :request do
  let(:dspace_fixtures) { File.read(File.join(fixture_path, 'spherical_torus.xml')) }
  let(:indexer) do
    DspaceIndexer.new(dspace_fixtures)
  end
  before do
    indexer.index
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
