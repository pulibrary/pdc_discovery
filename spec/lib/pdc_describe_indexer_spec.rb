# frozen_string_literal: true

RSpec.describe DescribeIndexer do
  describe 'indexing an RSS feed from PDC Describe' do
    let(:rss_feed) { File.read(File.join(fixture_path, 'pdc_describe', 'works.rss')) }
    let(:resource1) { File.read(File.join(fixture_path, 'pdc_describe', 'resource1.json')) }
    let(:resource2) { File.read(File.join(fixture_path, 'pdc_describe', 'resource2.json')) }
    let(:rss_url_string) { "https://pdc-describe-prod.princeton.edu/describe/works.rss" }
    let(:indexer) { described_class.new(rss_url: rss_url_string) }

    it "has a traject indexer" do
      expect(indexer.traject_indexer).to be_instance_of Traject::Indexer::NokogiriIndexer
    end

    context 'indexing to solr' do
      before do
        Blacklight.default_index.connection.delete_by_query("*:*")
        Blacklight.default_index.connection.commit
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works.rss")
          .to_return(status: 200, body: rss_feed, headers: {})
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/6.json")
          .to_return(status: 200, body: resource1, headers: {})
        stub_request(:get, "https://pdc-describe-prod.princeton.edu/describe/works/20.json")
          .to_return(status: 200, body: resource2, headers: {})
      end

      it "sends items to solr" do
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 0

        # If index_pdc_describe == false, do not index PDC Describe.
        # This is a safety measure so we don't index in production until we're ready
        # See config/pdc_discovery.yml to change this setting for real
        Rails.configuration.pdc_discovery.index_pdc_describe = false
        indexer.index
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 0

        # If index_pdc_describe == true, DO index PDC Describe.
        Rails.configuration.pdc_discovery.index_pdc_describe = true
        indexer.index
        response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
        expect(response["response"]["numFound"]).to eq 2
      end
    end
  end
end
