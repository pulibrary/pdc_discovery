# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetFile do
  describe "#download_url" do
    it "builds the proper URL" do
      hash = { name: "big file.zip", handle: "123/dsp456", sequence: 1 }
      file = described_class.from_hash(hash)
      expect(file.download_url).to eq "https://dataspace-dev.princeton.edu/bitstream/123/dsp456/1/big file.zip"
    end
  end
end
