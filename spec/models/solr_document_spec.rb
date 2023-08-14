# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable RSpec/ExampleLength
RSpec.describe SolrDocument do
  describe "#authors_et_al" do
    it "handles multiple authors" do
      doc = described_class.new({ id: "1", author_tesim: [] })
      expect(doc.authors_et_al).to eq ""

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck"] })
      expect(doc.authors_et_al).to eq "Eve Tuck"

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck", "K. Wayne Yang"] })
      expect(doc.authors_et_al).to eq "Eve Tuck & K. Wayne Yang"

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck", "K. Wayne Yang", "Jane Smith"] })
      expect(doc.authors_et_al).to eq "Eve Tuck et al."
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
      files = [{ name: "file1.zip" }, { name: "data.csv" }, { name: "file2.zip" }]
      doc = described_class.new({ id: "1", files_ss: files.to_json })
      zip_group = { extension: "zip", file_count: 2 }
      csv_group = { extension: "csv", file_count: 1 }
      expect(doc.file_counts[0]).to eq zip_group
      expect(doc.file_counts[1]).to eq csv_group
    end
  end

  describe "#authors_ordered" do
    it "handles order for PDC Describe records" do
      pdc_describe_data = JSON.parse(File.read(File.join(fixture_path, 'files', 'pppl1.json')))
      pdc_authors = pdc_describe_data["resource"]["creators"].to_json
      doc = described_class.new({ id: "1", authors_json_ss: pdc_authors })
      expect(doc.authors_ordered.first.sequence).to eq 1
      expect(doc.authors_ordered.first.value).to eq "Wang, Yin"
      expect(doc.authors_ordered.last.sequence).to eq 5
      expect(doc.authors_ordered.last.value).to eq "Ji, Hantao"
      expect(doc.authors_ordered.count).to eq 5
    end

    it "returns the authors unordered for DataSpace records" do
      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck", "K. Wayne Yang"] })
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

    it "returns the values for DataSpace records" do
      doc = described_class.new({ id: "1", subject_tesim: ["subject1", "subject2"] })
      expect(doc.subject.sort).to eq ["subject1", "subject2"]
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable RSpec/ExampleLength
