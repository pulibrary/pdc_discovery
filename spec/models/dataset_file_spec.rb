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
        name: "10.34770/qyrs-vg25/50/file_name.txt",
        full_name: "file_name.txt",
        size: 455_511,
        url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/qyrs-vg25/50/file_name.txt"
      }
      file = described_class.from_hash(hash, "pdc_describe")
      expect(file.download_url).to eq hash[:url]
    end
  end
  describe "sort Dataset files by name and size" do
  let(:file1) { DatasetFile.from_hash({
    name: "file_name.txt",
    size: "455511",
    download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/qyrs-vg25/50/file_name.txt"
  }, "pdc_describe") }
  let(:file2) { DatasetFile.from_hash({
    name: "Fig9b.hdf",
    size: "19271048",
    download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/Fig9b.hdf"
  }, "pdc_describe") }
  let(:file3) { DatasetFile.from_hash({
    name: "Fig8b.hdf",
    size: "5173",
    download_url: "https://g-ef94ef.f0ad1.36fe.data.globus.org/10.34770/bm4s-t361/89/readme.txt"
  }, "pdc_describe") }
  
  let(:file_array) {[file1, file2, file3]}
    it "sorts README files first" do
      expect(file_array).to sort_by(file_array.find("readme"))
      true 
    end
  end
end
