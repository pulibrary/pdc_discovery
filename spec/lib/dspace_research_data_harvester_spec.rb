# frozen_string_literal: true

RSpec.describe DspaceResearchDataHarvester do
  let(:rdh) { described_class.new }

  it "has a list of collections to index" do
    expect(rdh.collections_to_index.count).to eq 34
  end

  it "has a convenience method for indexing all collections" do
    expect_any_instance_of(described_class).to receive(:harvest).exactly(34).times
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
    let(:dspace_1308_items) { File.read(File.join(fixture_path, "migration", "1308_items.xml")) }
    let(:dspace_3386_items) { File.read(File.join(fixture_path, "migration", "3386_items.xml")) }

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

      stub_request(:get, "https://dataspace.princeton.edu/rest/collections/1308/items")
        .with(
          headers: {
            'Accept' => 'application/xml'
          }
        )
        .to_return(status: 200, body: dspace_1308_items, headers: {})

      stub_request(:get, "https://dataspace.princeton.edu/rest/collections/3386/items")
        .with(
        headers: {
          'Accept' => 'application/xml'
        }
      )
        .to_return(status: 200, body: dspace_3386_items, headers: {})
    end

    it "retrieves data from dspace and indexes it to solr" do
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      expect(response["response"]["numFound"]).to eq 0

      rdh.harvest(rdc)

      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      expect(response["response"]["numFound"]).to eq 32
    end

    context "migration tracking" do
      let(:shortened_collections_csv) { File.join(fixture_path, 'migration', 'collections.csv') }
      let(:tracking_csv) { File.join(fixture_path, "migration", 'dspace_migration.csv') }

      require 'csv'

      before do
        File.delete(tracking_csv) if File.exist? tracking_csv
        # Run migration queries against production, which is the only place all of this data exists
        allow(rdh).to receive(:server) { "https://dataspace.princeton.edu/rest" }
      end

      # The data for this comes from here: https://dataspace.princeton.edu/rest/collections/1308/items
      it "takes a dspace collection_id and produces a CSV file" do
        CSV.open(tracking_csv, "a") do |csv|
          csv << rdh.migration_csv_headers
        end
        collection = rdh.collections_to_index[2]
        rdh.produce_migration_spreadsheet(
                                          collection.parent_community,
                                          collection.community,
                                          collection.collection_name,
                                          collection.collection_id,
                                          tracking_csv
                                        )
        csv = CSV.parse(File.read(tracking_csv), headers: true)
        expect(csv[0]["title"]).to eq "Geometric concepts for stellarator permanent magnet arrays"
        expect(csv[0]["handle"]).to eq "88435/dsp01db78tg01d"
      end

      context "parent_community in a migration CSV" do
        let(:three_levels) { ["Princeton Plasma Physics Laboratory", "Advanced Projects", "Stellerators"] }
        let(:two_levels) { ["NA", "Princeton Plasma Physics Laboratory", "Plasma Science & Technology"] }
        it "is correct when there are three levels of hierarchy" do
          expect(rdh.csv_communities(three_levels)).to eq three_levels
        end
        it "is correct when there are two levels of hierarchy" do
          expect(rdh.csv_communities(two_levels)).to eq ["Princeton Plasma Physics Laboratory", "Plasma Science & Technology", ""]
        end
      end

      it "produces a CSV file for all items that need migration" do
        rdh.produce_full_migration_spreadsheet(tracking_csv, shortened_collections_csv)
        csv = CSV.parse(File.read(tracking_csv), headers: true)
        expect(csv[0]["title"]).to eq "Hyperdiffusion of dust particles in a turbulent tokamak plasma"
        expect(csv[8]["title"]).to eq "A novel scheme for error field correction in permanent magnet stellarators"
      end

      context "migration is already in progress" do
        let(:in_progress_csv) { File.join(fixture_path, "migration", 'migration_in_progress.csv') }

        it 'produces a csv for all items in need of migration not already on the in-progress spreadsheet' do
          rdh.produce_delta_migration_spreadsheet(tracking_csv, shortened_collections_csv, in_progress_csv)
          csv = CSV.parse(File.read(tracking_csv), headers: true)
          # The chatbot fixture is the only one that isn't in the migration in progress spreadsheet
          expect(csv[0]["title"]).to eq "Chatbots as social companions: Perceiving consciousness, human likeness, and social health benefits in machines"
          expect(csv.count).to eq 1
        end
      end
    end
  end


end
