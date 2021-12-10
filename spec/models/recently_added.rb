# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecentlyAdded do
  let(:recently_added) { file_fixture("recent.json") }
  context "with a valid URL" do
    before do
      stub_request(:get, "http://pdc-discovery-test/catalog.json").to_return(
        status: 200,
        body: recently_added,
        headers: {
          'Content-Type' => 'application/json;charset=UTF-8',
          'Accept' => 'application/json',
          'User-Agent' => 'Faraday v1.0.1'
        }
      )
    end

    # rubocop:disable RSpec/ExampleLength
    it "returns a payload of ten most recent items with required fields" do
      resp = described_class.feed("http://pdc-discovery-test")
      expect(resp.count).to eq 10
      expect(resp.first[1][:title]).to eq "Nonlinear fishbone dynamics in spherical tokamaks"
      expect(resp.first[1][:link]).to eq "http://localhost:3000/catalog/84912"
      expect(resp.first[1][:author]).to eq "Wang, F., Fu, G.Y., and Shen, W."
      expect(resp.first[1][:genre]).to eq "Dataset"
      expect(resp.first[1][:issue_date]).to eq "January 2017"
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "with an invalid URL" do
    # This test is important because the recently added feeds can be unavailable
    # immeditaly after a release.
    it "handles HTTP exceptions" do
      resp = described_class.feed("xttp://pdc-discovery-test")
      expect(resp).to be {}
    end
  end
end
