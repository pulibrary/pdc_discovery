# frozen_string_literal: true

RSpec.describe DspaceResearchDataHarvester do
  let(:rdh) { described_class.new }

  it "has a list of collections to index" do
    expect(rdh.collections_to_index.count).to eq 32
  end

  it "has a convenience method for indexing all collections" do
    expect_any_instance_of(described_class).to receive(:harvest).exactly(32).times
    described_class.harvest(true)
  end

  context "harvesting a collection" do
    let(:csv_data) do
      {
        "ParentCommunity" => "Princeton Plasma Physics Laboratory",
        "Community" => "Spherical Torus",
        "CollectionName" => "NSTX",
        "Handle" => "88435/dsp018p58pg29j",
        "CollectionID" => "1282",
        "ItemCount" => "33",
        nil => nil
      }
    end
    let(:csv_row) { CSV::Row.new(csv_data.keys, csv_data.values) }
    let(:rdc) { ResearchDataCollection.new(csv_row) }
    let(:collection_1282_xml) { File.read(File.join(fixture_path, 'spherical_torus.xml')) }

    before do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit

      stub_request(:get, "https://dataspace-dev.princeton.edu/rest/collections/1282/items?expand=all&limit=100&offset=0")
        .with(
          headers: {
            'Accept' => 'application/xml'
          }
        )
        .to_return(status: 200, body: collection_1282_xml, headers: {})
    end

    it "retrieves data from dspace and indexes it to solr" do
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      expect(response["response"]["numFound"]).to eq 0

      rdh.harvest(rdc)

      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      expect(response["response"]["numFound"]).to eq 32
    end
  end
end
