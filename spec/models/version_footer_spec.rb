# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionFooter do
  describe "info" do
    it "detects stale information" do
      described_class.revision_file = Pathname.new(fixture_path).join("REVISION").to_s
      described_class.revisions_logfile = Pathname.new(fixture_path).join("revisions_stale.log").to_s
      described_class.reset!
      info = described_class.info
      expect(info[:stale]).to be true
      expect(info[:sha]).to eq "2222ae5c4ad9aaa0faad5208f1bf8108bd5934bf"
      expect(info[:branch]).to eq "version-2"
      expect(info[:version]).to eq "02 December 2021"
    end

    it "detects current information" do
      described_class.revision_file = Pathname.new(fixture_path).join("REVISION").to_s
      described_class.revisions_logfile = Pathname.new(fixture_path).join("revisions_current.log").to_s
      described_class.reset!
      info = described_class.info
      expect(info[:stale]).to be false
      expect(info[:sha]).to eq "4443ae5c4ad9aaa0faad5208f1bf8108bd5934bf"
      expect(info[:branch]).to eq "version-3"
      expect(info[:version]).to eq "03 December 2021"
    end
  end
end
