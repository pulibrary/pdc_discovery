# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable RSpec/ExampleLength
RSpec.describe SolrDocument do
  describe "#authors_et_al" do
    it "handles multiple authors" do
      doc = described_class.new({ id: "1", authors_json_ss: "[]" })
      expect(doc.authors_et_al).to eq ""

      doc = described_class.new({ id: "1", authors_json_ss: "[{\"value\":\"Eve Tuck\",\"sequence\":1}]" })
      expect(doc.authors_et_al).to eq "Eve Tuck"

      doc = described_class.new({ id: "1", authors_json_ss: "[{\"value\":\"Eve Tuck\",\"sequence\":1},{\"value\":\"K. Wayne Yang\",\"sequence\":2}]" })
      expect(doc.authors_et_al).to eq "Eve Tuck & K. Wayne Yang"

      doc = described_class.new({ id: "1", authors_json_ss: "[{\"value\":\"Eve Tuck\",\"sequence\":1},{\"value\":\"K. Wayne Yang\",\"sequence\":2},{\"value\":\"Jane Smith\",\"sequence\":3}]" })
      expect(doc.authors_et_al).to eq "Eve Tuck et al."
    end
  end

  describe "#date_created" do
    it "handles pdc dates" do
      doc = described_class.new({ id: "1", issue_date_strict_ssi: "2024-10-30", data_source_ssi: "pdc_describe" })
      expect(doc.date_created).to eq "2024-10-30"

      doc = described_class.new({ id: "2", data_source_ssi: "pdc_describe" })
      expect(doc.date_created).to be nil
    end
  end

  describe "#date_modified" do
    it "handles pdc dates" do
      doc = described_class.new({ id: "1", pdc_updated_at_dtsi: "2024-10-30", data_source_ssi: "pdc_describe" })
      expect(doc.date_modified).to eq "2024-10-30"

      doc = described_class.new({ id: "2", data_source_ssi: "pdc_describe" })
      expect(doc.date_modified).to be nil

      doc = described_class.new({ id: "3", pdc_updated_at_dtsi: "2024-10-30T01:01:01Z", data_source_ssi: "pdc_describe" })
      expect(doc.date_modified).to eq "2024-10-30"

      doc = described_class.new({ id: "4", pdc_updated_at_dtsi: "string", data_source_ssi: "pdc_describe" })
      expect(doc.date_modified).to be nil
    end
  end

  describe "#icons_css" do
    it "handles icons for known genres" do
      doc = described_class.new({ id: "1", genre_ssim: ["Dataset"] })
      expect(doc.icon_css).to eq "bi-stack"

      doc = described_class.new({ id: "1", genre_ssim: ["moving image"] })
      expect(doc.icon_css).to eq "bi-film"
    end

    it "handles icon for an unknown genre" do
      doc = described_class.new({ id: "1", genre_ssim: ["unknown genre"] })
      expect(doc.icon_css).to eq "bi-file-earmark-fill"
    end
  end

  describe "#file_counts" do
    it "detects documents with no files attached" do
      doc = described_class.new({ id: "1" })
      expect(doc.file_counts.count).to eq 0
    end

    it "calculates file counts and sorts data descending by count" do
      files = [{ filename: "file1.zip", "size": 10_588, "display_size": "10.6 KB", "url": "https://example.com" },
               { filename: "data.csv", "size": 10_588, "display_size": "10.6 KB", "url": "https://example.com" },
               { filename: "file2.zip", "size": 10_588, "display_size": "10.6 KB", "url": "https://example.com" }]
      doc = described_class.new({ id: "1", pdc_describe_json_ss: { files: files }.to_json })
      zip_group = { extension: "zip", file_count: 2 }
      csv_group = { extension: "csv", file_count: 1 }
      expect(doc.file_counts[0]).to eq zip_group
      expect(doc.file_counts[1]).to eq csv_group
    end
  end

  describe "#authors_ordered" do
    it "handles order for PDC Describe records" do
      pdc_describe_data = JSON.parse(File.read(File.join(fixture_paths.first, 'files', 'pppl1.json')))
      pdc_authors = pdc_describe_data["resource"]["creators"].to_json
      doc = described_class.new({ id: "1", authors_json_ss: pdc_authors })
      expect(doc.authors_ordered.first.sequence).to eq 1
      expect(doc.authors_ordered.first.value).to eq "Wang, Yin"
      expect(doc.authors_ordered.last.sequence).to eq 5
      expect(doc.authors_ordered.last.value).to eq "Ji, Hantao"
      expect(doc.authors_ordered.count).to eq 5
    end

    it "returns the authors unordered if a sequence is not present" do
      doc = described_class.new({ id: "1", authors_json_ss: "[{\"value\":\"Eve Tuck\"},{\"value\":\"K. Wayne Yang\"}]" })
      expect(doc.authors_ordered.first.sequence).to eq 0
      expect(doc.authors_ordered.last.sequence).to eq 0
      expect(doc.authors_ordered.any? { |author| author.value == "Eve Tuck" }).to eq true
      expect(doc.authors_ordered.count).to eq 2
    end
  end

  describe "#globus_uri" do
    let(:globus_uri_ssi) { "https://app.globus.org/file-manager?origin_id=xx&origin_path=%2Ffoldern%2Ffile.txt" }
    let(:uri_ssim) { ["https://princeton.edu", "https://app.globus.org/something/something"] }
    it "returns the indexed value when available" do
      doc = described_class.new({ id: "1", globus_uri_ssi: globus_uri_ssi, uri_ssim: uri_ssim })
      expect(doc.globus_uri).to eq "https://app.globus.org/file-manager?origin_id=xx&origin_path=%2Ffoldern%2Ffile.txt"
    end

    it "returns the value from the URIs" do
      doc = described_class.new({ id: "1", uri_ssim: uri_ssim })
      expect(doc.globus_uri).to eq "https://app.globus.org/something/something"
    end
  end

  describe "#globus_uri_from_description" do
    it "returns nil when no Globus URI available in the description" do
      doc = described_class.new({ id: "1", author_tesim: [] })
      expect(doc.globus_uri_from_description).to be nil

      doc = described_class.new({ id: "1", description_tsim: ["no globus URI in here"] })
      expect(doc.globus_uri_from_description).to be nil
    end

    it "returns the Globus URI when it is available in the description" do
      doc = described_class.new({ id: "1", description_tsim: ["xxx https://app.globus.org/file-manager?origin_id=dc43f461-0ca7-4203-848c-33a9fc00a464&origin_path=%2F yyy"] })
      expect(doc.globus_uri_from_description).to eq "https://app.globus.org/file-manager?origin_id=dc43f461-0ca7-4203-848c-33a9fc00a464&origin_path=%2F"
    end
  end

  describe "#subjects" do
    it "returns the values for PDC Describe records" do
      doc = described_class.new({ id: "1", data_source_ssi: "pdc_describe", subject_all_ssim: ["subject1", "subject2"] })
      expect(doc.subject.sort).to eq ["subject1", "subject2"]
    end
  end

  describe "#embargo_date" do
    subject(:solr_document) { described_class.new({ id: "1", embargo_date_dtsi: embargo_date_dtsi }) }
    let(:embargo_date) { Date.parse(embargo_date_dtsi) }

    context "when the embargo is available as a datestamp" do
      let(:embargo_date_dtsi) { "2033-09-15T17:33:18Z" }

      it "parses the embargo date timestamp into a Date object" do
        expect(solr_document.embargo_date).to be_a(Date)
        expect(solr_document.embargo_date).to eq(embargo_date)
      end
    end

    context "when the embargo is invalid" do
      let(:embargo_date_dtsi) { "invalid" }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it "returns a nil value and logs a warning" do
        expect(solr_document.embargo_date).to be nil
        expect(Rails.logger).to have_received(:warn).with("Failed to parse the embargo date value for #{solr_document.id}: invalid. The error was: invalid date")
      end
    end
  end

  describe "#embargoed?" do
    subject(:solr_document) { described_class.new({ id: "1", embargo_date_dtsi: embargo_date_dtsi }) }

    context "when the embargo is active" do
      let(:embargo_date_dtsi) { "2033-05-20T17:33:18Z" }

      it "indicates that the Document is active for the PDC Describe work" do
        expect(solr_document.embargoed?).to be true
      end
    end

    context "when the embargo has expired" do
      let(:embargo_date_dtsi) { "1972-05-20T17:33:18Z" }

      it "does not indicate that the Document is active for the PDC Describe work" do
        expect(solr_document.embargoed?).to be false
      end
    end

    context "when the embargo date is invalid" do
      let(:embargo_date_dtsi) { "invalid" }

      it "indicates that the Document is active for the PDC Describe work" do
        expect(solr_document.embargoed?).to be true
      end
    end
  end

  describe "#community_path" do
    subject(:solr_document) { described_class.new({ id: "1" }) }
    it "returns community path" do
      expect { solr_document.community_path }.not_to raise_error
    end
  end

  describe "#collection_name" do
    subject(:solr_document) { described_class.new({ id: "1" }) }
    it "returns collection name" do
      expect { solr_document.collection_name }.not_to raise_error
    end
  end

  describe "#methods" do
    subject(:solr_document) { described_class.new({ id: "1" }) }
    it "returns methods" do
      expect { solr_document.methods }.not_to raise_error
    end
  end

  describe "#bibtex_id" do
    subject(:solr_document) { described_class.new({ id: "1" }) }
    it "returns id for bibtex citation" do
      expect { solr_document.bibtex_id }.not_to raise_error
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable RSpec/ExampleLength
