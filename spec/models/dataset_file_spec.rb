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
end
