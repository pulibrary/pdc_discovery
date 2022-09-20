# frozen_string_literal: true

RSpec.describe DspaceIndexer do
  describe 'indexing a single record' do
    let(:single_item) { file_fixture("single_item.xml").read }
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
        expect(indexed_record["author_tesim"]).to eq authors
      end

      it "contributor" do
        expect(indexed_record["contributor_tsim"]).to contain_exactly "Stotler, Daren"
      end

      it "description" do
        expect(indexed_record["description_tsim"].first).to match(/This dataset is too large to download directly from this item page./)
      end

      it "issue_date" do
        expect(indexed_record["issue_date_ssim"]).to contain_exactly "August 2015"
      end

      it "title" do
        expect(indexed_record["title_tesim"]).to contain_exactly "Midplane neutral density profiles in the National Spherical Torus Experiment"
      end

      it "uri" do
        expect(indexed_record["uri_tesim"]).to contain_exactly "http://arks.princeton.edu/ark:/88435/dsp01zg64tp300"
      end
    end

    context "contributor" do
      it "advisor" do
        expect(indexed_record["advisor_tesim"]).to contain_exactly "Fake Advisor"
      end

      it "editor" do
        expect(indexed_record["editor_tesim"]).to contain_exactly "Fake Editor"
      end

      it "illustrator" do
        expect(indexed_record["illustrator_tesim"]).to contain_exactly "Fake Illustrator"
      end

      it "other contributor" do
        expect(indexed_record["other_contributor_tsim"]).to contain_exactly "Fake Other"
      end

      it "creator" do
        expect(indexed_record["creator_tesim"]).to contain_exactly "Fake Creator"
      end
    end

    context "coverage" do
      it "spatial" do
        expect(indexed_record["spatial_coverage_tesim"]).to contain_exactly "Narnia"
      end
      it "temporal" do
        expect(indexed_record["temporal_coverage_tesim"]).to contain_exactly "A long time ago"
      end
    end

    context "dates" do
      it "copyright date" do
        expect(indexed_record["copyright_date_ssim"]).to contain_exactly "2 May 1976"
      end
      it "date" do
        expect(indexed_record["date_ssim"]).to contain_exactly "19 September 2015"
      end
      it "date accessioned" do
        expect(indexed_record["date_accessioned_ssim"]).to contain_exactly "18 August 2015"
      end
      it "date available" do
        expect(indexed_record["date_available_ssim"]).to contain_exactly "11 November 2016"
      end
      it "date created" do
        expect(indexed_record["date_created_ssim"]).to contain_exactly "1 May 1976"
      end
      it "date submitted" do
        expect(indexed_record["date_submitted_ssim"]).to contain_exactly "6 August 2015"
      end
    end

    context "dc.description" do
      it "provenance" do
        expect(indexed_record["provenance_ssim"]).to contain_exactly "Fake Provenance"
      end
      it "sponsorship" do
        expect(indexed_record["sponsorship_ssim"]).to contain_exactly "Fake Sponsorship"
      end
      it "statementofresponsibility" do
        expect(indexed_record["statementofresponsibility_ssim"]).to contain_exactly "Fake Statement of Responsibility"
      end
      it "tableofcontents" do
        expect(indexed_record["tableofcontents_tesim"]).to contain_exactly "readme.txt (table of contents), Stotler_PoP.zip"
      end
      it "description uri" do
        expect(indexed_record["description_uri_ssim"]).to contain_exactly "http://fake.description.uri"
      end
    end

    context "identifiers" do
      it "dc.identifier" do
        expect(indexed_record["other_identifier_ssim"]).to contain_exactly "mst3k"
      end
      it "dc.identifier.citation" do
        expect(indexed_record["citation_ssim"]).to contain_exactly "This is a fake citation."
      end
      it "dc.identifier.govdoc" do
        expect(indexed_record["govdoc_id_ssim"]).to contain_exactly "fake.govdoc.id"
      end
      it "dc.identifier.isbn" do
        expect(indexed_record["isbn_ssim"]).to contain_exactly "0-13-117705-2"
      end
      it "dc.identifier.issn" do
        expect(indexed_record["issn_ssim"]).to contain_exactly "0-123-456789"
      end
      it "dc.identifier.sici" do
        expect(indexed_record["sici_ssim"]).to contain_exactly "987654321"
      end
      it "dc.identifier.ismn" do
        expect(indexed_record["ismn_ssim"]).to contain_exactly "0000-1111-0000"
      end
      it "dc.identifier.other" do
        expect(indexed_record["local_id_ssim"]).to contain_exactly "12345-67890"
      end
    end
  end
end
