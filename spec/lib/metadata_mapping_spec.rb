# frozen_string_literal: true

RSpec.describe Indexer do
  describe 'indexing a single record' do
    let(:single_item) { File.read(File.join(fixture_path, 'single_item.xml')) }
    let(:indexer) do
      described_class.new(single_item)
    end
    let(:indexed_record) do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      response["response"]["docs"].first
    end

    context "fields for above the fold single page display" do
      it "abstract" do
        expect(indexed_record["abstract_tsim"].first).to match(/discharge parameters/)
      end

      it "author" do
        authors = ['Stotler, D.', 'F. Scotti', 'R.E. Bell', 'A. Diallo', 'B.P. LeBlanc', 'M. Podesta', 'A.L. Roquemore', 'P.W. Ross']
        expect(indexed_record["author_tsim"]).to eq authors
      end

      it "contributor" do
        expect(indexed_record["contributor_tsim"]).to contain_exactly "Stotler, Daren"
      end

      it "description" do
        expect(indexed_record["description_tsim"]).to contain_exactly "This is a fake description."
      end

      it "editor" do
        expect(indexed_record["editor_tsim"]).to contain_exactly "Fake Editor"
      end

      it "issue_date" do
        expect(indexed_record["issue_date_ssm"]).to contain_exactly "August 2015"
      end

      it "title" do
        expect(indexed_record["title_ssm"]).to contain_exactly "Midplane neutral density profiles in the National Spherical Torus Experiment"
        expect(indexed_record["title_tsim"]).to contain_exactly "Midplane neutral density profiles in the National Spherical Torus Experiment"
      end

      it "uri" do
        expect(indexed_record["uri_tsim"]).to contain_exactly "http://arks.princeton.edu/ark:/88435/dsp01zg64tp300"
      end
    end

    context "dates" do
      it "copyright date" do
        expect(indexed_record["copyright_date_ssm"]).to contain_exactly "2 May 1976"
      end
      it "date" do
        expect(indexed_record["date_ssm"]).to contain_exactly "19 September 2015"
      end
      it "date accessioned" do
        expect(indexed_record["date_accessioned_ssm"]).to contain_exactly "18 August 2015"
      end
      it "date available" do
        expect(indexed_record["date_available_ssm"]).to contain_exactly "11 November 2016"
      end
      it "date created" do
        expect(indexed_record["date_created_ssm"]).to contain_exactly "1 May 1976"
      end
      it "date submitted" do
        expect(indexed_record["date_submitted_ssm"]).to contain_exactly "6 August 2015"
      end
    end
  end
end
