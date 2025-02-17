# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetFile do
  describe "#download_url" do
    it "builds the proper URL for a DataSpace record" do
      hash = { name: "big file.zip", handle: "123/dsp456", sequence: 1 }
      file = described_class.from_hash(hash, "dataspace")
      expect(file.download_url).to eq "https://dataspace-dev.princeton.edu/bitstream/123/dsp456/1"
    end

    it "builds the proper URL for a PDC Describe record" do
      hash = {
        filename: "10.34770/qyrs-vg25/50/file_name.txt",
        name: "file_name.txt",
        size: 455_511,
        url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/qyrs-vg25/50/file_name.txt"
      }
      file = described_class.from_hash(hash, "pdc_describe")
      expect(file.download_url).to eq hash[:url]
    end
  end

  describe "#display_filename" do
    it "handles normal cases correctly" do
      expect(described_class.filename_without_doi("10.123/4567/40/file1.txt")).to eq "file1.txt"
      expect(described_class.filename_without_doi("10.123/4567/40/folder1/file1.txt")).to eq "folder1/file1.txt"
    end

    it "defaults to the full path when DOI is not present" do
      expect(described_class.filename_without_doi("file1.txt")).to eq "file1.txt"
      expect(described_class.filename_without_doi("folder1/file1.txt")).to eq "folder1/file1.txt"
    end

    it "defaults to full path when database ID is not numeric" do
      expect(described_class.filename_without_doi("10.123/4567/x40/file1.txt")).to eq "10.123/4567/x40/file1.txt"
    end

    it "handles nulls and empty values" do
      expect(described_class.filename_without_doi("")).to eq ""
      expect(described_class.filename_without_doi(nil)).to eq ""
    end
  end

  describe "sort Dataset files by name and size" do
    let(:file1) do
      DatasetFile.from_hash({
                              name: "b.txt",
                              filename: "10.34770/bm4s-t361/89/b.txt",
                              size: "455511",
                              download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/b.txt"
                            }, "pdc_describe")
    end
    let(:file2) do
      DatasetFile.from_hash({
                              name: "a.txt",
                              filename: "10.34770/bm4s-t361/89/a.txt",
                              size: "19271048",
                              download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/a.txt"
                            }, "pdc_describe")
    end
    let(:file3) do
      DatasetFile.from_hash({
                              name: "README.txt",
                              filename: "10.34770/bm4s-t361/89/README.txt",
                              size: "5173",
                              download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/README.txt"
                            }, "pdc_describe")
    end

    let(:file_array) { [file1, file2, file3] }
    it "sorts README files first" do
      expect(file_array.first.name).to eq "b.txt"
      sorted_file_array = DatasetFile.sort_file_array(file_array)
      expect(sorted_file_array.first.name).to eq "README.txt"
    end
    it "sorts everything else alphabetically" do
      expect(file_array.map(&:name)).to eq ["b.txt", "a.txt", "README.txt"]
      sorted_file_array = DatasetFile.sort_file_array(file_array)
      expect(sorted_file_array.map(&:name)).to eq ["README.txt", "a.txt", "b.txt"]
    end
  end
end
