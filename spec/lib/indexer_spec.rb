# frozen_string_literal: true

RSpec.describe Indexer do
  describe 'indexing a community from DataSpace' do
    let(:community_fetch_with_expanded_metadata) { File.read(File.join(fixture_path, 'astrophysical_sciences.xml')) }
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
    end
  end
end