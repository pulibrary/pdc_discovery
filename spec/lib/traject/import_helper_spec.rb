# frozen_string_literal: true
require "./lib/traject/import_helper.rb"

RSpec.describe ImportHelper do
  describe "#display_filename" do
    it "handles normal cases correctly" do
      doi = "10.123/4567"
      expect(described_class.display_filename("10.123/4567/40/file1.txt", doi)).to eq "file1.txt"
      expect(described_class.display_filename("10.123/4567/40/folder1/file1.txt", doi)).to eq "folder1/file1.txt"
    end

    it "defaults to the full path DOI is not present" do
      expect(described_class.display_filename("10.123/4567/40/file1.txt", nil)).to eq "10.123/4567/40/file1.txt"
      expect(described_class.display_filename("10.123/4567/40/file1.txt", "")).to eq "10.123/4567/40/file1.txt"
    end

    it "defaults to full path when path does not start with the DOI" do
      expect(described_class.display_filename("10.123/4567/40/file1.txt", "10.123/9999")).to eq "10.123/4567/40/file1.txt"
    end

    it "defaults to full path when database ID is not numeric" do
      expect(described_class.display_filename("10.123/4567/x40/file1.txt", "10.123/4567")).to eq "10.123/4567/x40/file1.txt"
    end
  end
end
