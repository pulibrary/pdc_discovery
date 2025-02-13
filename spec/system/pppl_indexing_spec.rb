# frozen_string_literal: true
require 'rails_helper'

describe 'PPPL research data indexing', type: :system do
  let(:processed) do
    indexer.process(dspace_xml_io)
    indexer.complete
  end
  let(:query_sort) { 'internal_id_lsi desc' }
  let(:blacklight_index) { Blacklight.default_index }
  let(:blacklight_connection) { blacklight_index.connection }
  let(:documents) do
    processed
    http_response = blacklight_connection.select(q: '*:*', params: { rows: 100, sort: query_sort })
    solr_response = http_response['response']
    solr_response['docs']
  end
  let(:output) { TrajectOutput.new }
  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.load_config_file(Rails.root.join('config', 'traject', 'dataspace_research_data_config.rb'))
    end
  end
  let(:dspace_xml) do
    File.join(fixture_paths.first, 'astrophysical_sciences.xml')
  end
  let(:dspace_xml_io) { File.read(dspace_xml) }
  let(:nokogiri_reader) do
    Traject::NokogiriReader.new(dspace_xml_io, indexer.settings)
  end
  let(:records) do
    nokogiri_reader.to_a
  end

  before do
    class TrajectOutput < Array
      def put(context)
        push(context.output_hash)
      end
    end

    blacklight_connection.delete_by_query('*:*')
    blacklight_connection.commit
  end

  after do
    Object.send(:remove_const, :TrajectOutput)
    blacklight_connection.delete_by_query('*:*')
    blacklight_connection.commit
  end

  context "when the XML documents has been indexed" do
    let(:first_document) { documents.first }
    let(:last_document) { documents.last }

    before do
      documents
    end

    it 'indexes all XML documents' do
      expect(documents).not_to be_empty
      expect(documents.length).to eq(39)
    end

    it 'indexes the IDs' do
      expect(first_document).to include('id')
      expect(first_document['id']).to eq('104131')
      expect(last_document).to include('id')
      expect(last_document['id']).to eq('777')
    end

    context "when indexing XML documents in a different initial order" do
      let(:records) do
        values = nokogiri_reader.to_a
        values.shuffle
      end

      it 'orders the document IDs consistently' do
        expect(first_document).to include('id')
        expect(first_document['id']).to eq('104131')
        expect(last_document).to include('id')
        expect(last_document['id']).to eq('777')
      end
    end

    it 'indexes the titles' do
      expect(first_document).to include('title_tesim')
      titles = first_document['title_tesim']
      expect(titles).not_to be_empty
      expect(titles.length).to eq(1)
      first_title = titles.first
      expect(first_title).to eq('The Dark Side of the Gravitational Force: Lessons from Astrophysics on Gravity, Black Holes, and Dark Matter')
    end

    it 'indexes the DOI into the `referenced_by` field' do
      expect(documents.length).to eq(39)
      third_document = documents[-3]
      expect(third_document).to include('referenced_by_ssim')
      references = third_document['referenced_by_ssim']
      expect(references).not_to be_empty
      reference = references.first
      expect(reference).to eq('https://arxiv.org/abs/1903.06605')
    end

    it 'indexes the file metadata' do
      expect(last_document).to include('files_ss')
      files_values = last_document['files_ss']
      files = JSON.parse(files_values)

      expect(files.count).to eq(1)
      first_file = files.first
      expect(first_file["name"]).to eq('Sironi_princeton_0181D_10002.pdf')
    end
  end
end
