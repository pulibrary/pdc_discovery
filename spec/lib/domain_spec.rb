# frozen_string_literal: true

require "./lib/traject/domain.rb"

RSpec.describe Domain do
  describe '#from_community' do
    it "handles unknown communities" do
      expect(described_class.from_community("nope")).to be nil
      expect(described_class.from_community(nil)).to be nil
    end

    it "handles known communities" do
      expect(described_class.from_community("Economics")).to eq "Social Sciences"
    end
  end

  describe '#from_communities' do
    it "handles multiple domains" do
      expect(described_class.from_communities(["Economics", "Physics"])).to eq ["Social Sciences", "Natural Sciences"]
    end

    it "handles duplicate domains" do
      expect(described_class.from_communities(["Economics", "Computational Social Science"])).to eq ["Social Sciences"]
    end

    it "handles nils" do
      expect(described_class.from_communities(["Economics", nil, "Physics"])).to eq ["Social Sciences", "Natural Sciences"]
    end
  end
end
