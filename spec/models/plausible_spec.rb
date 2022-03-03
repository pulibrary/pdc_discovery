# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe Plausible do
  before do
    stub_request(:get, "https://plausible.io/api/v1/stats/breakdown?filters=event:page==/discovery/catalog/88163&metrics=visitors,pageviews&property=event:props:filename&site_id=pdc-discovery-staging.princeton.edu")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer no-key-for-testing',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(
        status: 200,
        body: file_fixture("plausible_breakdown_catalog_88163.json"),
        headers: { 'content-type' => 'application/json; charset=utf-8' }
      )
  end

  describe "#downloads" do
    it "rolls up downloads" do
      ENV['PLAUSIBLE_KEY'] = 'no-key-for-testing'
      expect(described_class.downloads('88163')).to eq 6
      ENV['PLAUSIBLE_KEY'] = nil
    end
  end
end
# rubocop:enable Layout/LineLength
