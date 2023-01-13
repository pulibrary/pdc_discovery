# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe DescribeIndexer do
  describe 'indexing a single record' do
    let(:single_item) { file_fixture("bitklavier_binaural.json").read }
    let(:indexer) do
      described_class.new(rss_url: "file://whatever.rss")
    end
    let(:indexed_record) do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index_one(single_item)
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      response["response"]["docs"].first
    end

    context "basic fields" do
      ##
      # The id is based on the DOI
      # A doi of 10.34770/r75s-9j74 will become doi-10-34770-r75s-9j74
      it "id" do
        expect(indexed_record["id"]).to eq "doi-10-34770-r75s-9j74"
      end

      it "author" do
        expect(indexed_record["author_tesim"]).to eq ['Trueman, Daniel']
      end

      it "description" do
        description = "The bitKlavier Grand consists"
        expect(indexed_record["description_tsim"].first.include?(description)).to be true
      end

      it "contributors" do
        expect(indexed_record["contributor_tsim"].include?("Villalta, Andrés")).to eq true
        expect(indexed_record["contributor_tsim"].include?("Chou, Katie")).to eq true
        expect(indexed_record["contributor_tsim"].include?("Ayres, Christien")).to eq true
        expect(indexed_record["contributor_tsim"].include?("Wang, Matthew")).to eq true
      end

      it "title" do
        # title includes all titles
        main_title = "bitKlavier Grand Sample Library—Binaural Mic Image"
        alt_title = "alter title for bitKlavier"
        expect(indexed_record["title_tesim"].include?(main_title)).to eq true
        expect(indexed_record["title_tesim"].include?(alt_title)).to eq true
        # alt title does not include the main title
        expect(indexed_record["alternative_title_tesim"].include?(main_title)).to eq false
        expect(indexed_record["alternative_title_tesim"].include?(alt_title)).to eq true
      end

      it "rights" do
        expect(indexed_record["rights_name_ssi"]).to eq "GNU General Public License"
        expect(indexed_record["rights_uri_ssi"]).to eq "https://www.gnu.org/licenses/gpl-3.0.en.html"
      end

      it "keywords" do
        expect(indexed_record["subject_all_ssim"].include?("keyword1")).to eq true
        expect(indexed_record["subject_all_ssim"].include?("keyword2")).to eq true
        expect(indexed_record["subject_all_ssim"].include?("keyword3")).to eq true
      end

      it "collection tag" do
        expect(indexed_record["collection_tag_ssim"].include?("Humanities")).to eq true
        expect(indexed_record["collection_tag_ssim"].include?("Something else")).to eq true
      end

      it "community" do
        expect(indexed_record["community_name_ssi"]).to eq "Research Data"
      end

      it "genre_ssim" do
        expect(indexed_record["genre_ssim"].first).to eq "Dataset"
      end

      it "issue_date_ssim" do
        expect(indexed_record["issue_date_ssim"].first).to eq "2021"
      end

      it "publisher_ssim" do
        expect(indexed_record["publisher_ssim"].first).to eq "Princeton University"
      end

      xit 'referenced_by' do
        expect(result['referenced_by_ssim'].first).to eq 'https://arxiv.org/abs/1903.06605'
      end
    end

    context "uris" do
      it "stores full URL for ARK and DOI" do
        expect(indexed_record["uri_ssim"].include?("http://arks.princeton.edu/ark:/88435/dsp015999n653h")).to eq true
        expect(indexed_record["uri_ssim"].include?("https://doi.org/10.34770/r75s-9j74")).to eq true
      end
    end

    context "files" do
      # TODO: Index filenames for PDC Describe objects
      xit 'files' do
        # The fixture has three files but we expect two of them to be ignored
        files = JSON.parse(result['files_ss'].first)
        expect(files.count).to eq 1
        expect(files.first["name"]).to eq 'Lee_princeton_0181D_10086.pdf'
      end
    end
  end

  describe 'indexing an RSS feed from PDC Describe' do
    let(:rss_feed) { file_fixture("works.rss").read }
    let(:resource1) { file_fixture("bitklavier_binaural.json").read }
    let(:resource2) { file_fixture("sowing_the_seeds.json").read }
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
# rubocop:enable Metrics/BlockLength
