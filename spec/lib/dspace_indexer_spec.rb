# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DspaceIndexer do
  describe 'indexing a community from DataSpace' do
    let(:community_fetch_with_expanded_metadata) { File.read(File.join(fixture_paths.first, 'astrophysical_sciences.xml')) }
    let(:indexer) do
      described_class.new(community_fetch_with_expanded_metadata)
    end

    it "has a traject indexer" do
      expect(indexer.traject_indexer).to be_instance_of Traject::Indexer::NokogiriIndexer
    end

    context 'indexing to solr' do
      before do
        Blacklight.default_index.connection.delete_by_query("*:*")
        Blacklight.default_index.connection.commit
      end

      it "sends items to solr" do
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 0
        indexer.index
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 39
      end

      it "skips records already imported from PDC Describe" do
        # q=data_source_ssi:pdc_describe AND uri_ssim:http://arks.princeton.edu/ark:/88435/dsp017s75df84b
        solr_query_regex = /.*q=data_source_ssi\:pdc_describe\sAND\suri_ssim\:\"http\:\/\/arks.princeton.edu\/ark\:\/88435\/dsp017s75df84b\"/
        stub_request(:get, solr_query_regex).to_return(status: 200, body: '{"response":{"numFound":1}}', headers: {})

        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 0
        indexer.index
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 38
      end

      context "when an error is raised" do
        before do
          indexer.traject_indexer.configure do
            to_field 'id' do |_, _, _|
              raise(StandardError, "I just like raising errors")
            end
          end

          allow(indexer.traject_indexer.logger).to receive(:error)
        end

        it "propagates StandardError instances" do
          expect { indexer.index }.to raise_error(StandardError, "I just like raising errors")

          expect(indexer.traject_indexer.logger).not_to be_falsy
          expect(indexer.traject_indexer.logger).to have_received(:error).with(/Unexpected error on record/).at_least(:once)
        end
      end

      context "when a max skipped records error is raised" do
        before do
          indexer.traject_indexer.configure do
            to_field 'id' do |_, _, _|
              raise(Traject::SolrJsonWriter::MaxSkippedRecordsExceeded)
            end
          end

          allow(indexer.traject_indexer.logger).to receive(:error)
        end

        it "only logs an error message" do
          indexer.index

          expect(indexer.traject_indexer.logger).not_to be_falsy
          expect(indexer.traject_indexer.logger).to have_received(:error).with("Encountered exception: Traject::SolrJsonWriter::MaxSkippedRecordsExceeded").at_least(:once)
        end
      end
    end

    context 'invoking from CLI' do
      let(:astrophysical_sciences_handle) { "88435/dsp015m60qr913" }
      let(:options) do
        {
          collection_handle: astrophysical_sciences_handle
        }
      end

      before do
        stub_request(:get, "https://dataspace-dev.princeton.edu/rest/collections/261/items?expand=all&limit=100&offset=0")
          .with(
            headers: {
              'Accept' => 'application/xml'
            }
          )
          .to_return(status: 200, body: community_fetch_with_expanded_metadata, headers: {})
      end

      it 'is easy to invoke from thor' do
        expect(described_class.index(options)).to be_instance_of(described_class)
      end
    end
  end
end
