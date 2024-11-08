# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe VersionFooter do
  before do
    described_class.reset!
  end

  describe "info" do
    context "with stale information" do
      before do
        described_class.revision_file = Pathname.new(fixture_paths.first).join("REVISION").to_s
        described_class.revisions_logfile = Pathname.new(fixture_paths.first).join("revisions_stale.log").to_s
        described_class.reset!
      end

      xit "detects stale information" do # like rollback is influenced by current setting @@stale to false and then it not getting set back
        info = described_class.info
        expect(info[:stale]).to be true
        expect(info[:sha]).to eq "2222ae5c4ad9aaa0faad5208f1bf8108bd5934bf"
        expect(info[:branch]).to eq "version-2"
        expect(info[:version]).to eq "02 December 2021"
        expect(info[:tagged_release]).to be false
      end
    end

    context "with current information" do
      before do
        described_class.revision_file = Pathname.new(fixture_paths.first).join("REVISION").to_s
        described_class.revisions_logfile = Pathname.new(fixture_paths.first).join("revisions_current.log").to_s
        described_class.reset!
      end
      it "detects current information" do
        info = described_class.info
        expect(info[:stale]).to be false
        expect(info[:sha]).to eq "7a3b1d7c0f77db526963568ece3e0bb5a6399ce4"
        expect(info[:branch]).to eq "v0.8.0"
        expect(info[:version]).to eq "10 December 2021"
        expect(info[:tagged_release]).to be true
      end
    end

    context "with rollback information" do
      before do
        described_class.revision_file = Pathname.new(fixture_paths.first).join("REVISION").to_s
        described_class.revisions_logfile = Pathname.new(fixture_paths.first).join("revisions_rollback.log").to_s
        described_class.reset!
      end
      it "detects current information" do
        info = described_class.info
        expect(info[:stale]).to be true
        expect(info[:sha]).to eq "to"
        expect(info[:branch]).to eq "rolled"
        expect(info[:version]).to eq "(Deployment date could not be parsed from: deploy rolled back to release 20211210150445\n.)"
        expect(info[:tagged_release]).to be false
      end
    end
  end
end
