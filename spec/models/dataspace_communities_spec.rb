# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataspaceCommunities do
  let(:communities) { described_class.new('./spec/fixtures/files/dataspace_communities.json') }

  describe "#find_by_id" do
    it "finds a root community" do
      astrophysical = communities.find_by_id(186)
      expect(astrophysical.name).to eq "Astrophysical Sciences"
      expect(astrophysical.parent_id).to be nil
      expect(astrophysical.collections.count).to eq 1
    end

    it "finds a subcommunity" do
      adv_projects = communities.find_by_id(347)
      expect(adv_projects.name).to eq "Advanced Projects"
      expect(adv_projects.parent_id).to eq 346
    end
  end

  describe "#find_root_name" do
    it "reports root name for a root community" do
      # We expect root communities to report their name as root.
      pppl_id = 346
      expect(communities.find_root_name(pppl_id)).to eq "Princeton Plasma Physics Laboratory"
    end
    it "reports root name for a subcommunity" do
      pppl_adv_projects_id = 347
      expect(communities.find_root_name(pppl_adv_projects_id)).to eq "Princeton Plasma Physics Laboratory"
    end
  end

  describe "#find_path_name" do
    it "finds path for a root community" do
      expect(communities.find_path_name(346)).to eq ["Princeton Plasma Physics Laboratory"]
    end
    it "finds path for a subcommunity" do
      expect(communities.find_path_name(347)).to eq ["Princeton Plasma Physics Laboratory", "Advanced Projects"]
    end
  end
end
