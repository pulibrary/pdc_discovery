# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
RSpec.describe Plausible do
  let(:url) do
    plausible = "https://plausible.io/api/v1"
    date_period = "2021-01-01,#{Time.zone.today.strftime('%Y-%m-%d')}"
    "#{plausible}/stats/breakdown?filters=event:page==/discovery/catalog/88163&metrics=visitors,pageviews&property=event:props:filename&site_id=pdc-discovery-staging.princeton.edu&period=custom&date=#{date_period}"
  end

  before do
    stub_request(:get, url)
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

    context "a lasting error" do
      before do
        stub_request(:get, url)
          .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer no-key-for-testing',
            'User-Agent' => 'Ruby'
          }
        )
          .to_return(
          status: 500,
          body: { "error" => "an error" }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' }
        )
      end

      it "returns zero" do
        allow(Honeybadger).to receive(:notify)
        ENV['PLAUSIBLE_KEY'] = 'no-key-for-testing'
        expect(described_class.downloads('88163')).to eq 0
        expect(Honeybadger).not_to have_received(:notify)
        ENV['PLAUSIBLE_KEY'] = nil
      end
    end

    context "a intermittent error" do
      before do
        stub_request(:get, url)
          .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer no-key-for-testing',
            'User-Agent' => 'Ruby'
          }
        )
          .to_return({
                       status: 500,
                       body: { "error" => "an error" }.to_json,
                       headers: { 'content-type' => 'application/json; charset=utf-8' }
                     },
                    {
                      status: 200,
                      body: file_fixture("plausible_breakdown_catalog_88163.json"),
                      headers: { 'content-type' => 'application/json; charset=utf-8' }
                    })
      end

      it "rolls up downloads" do
        allow(Honeybadger).to receive(:notify)
        ENV['PLAUSIBLE_KEY'] = 'no-key-for-testing'
        expect(described_class.downloads('88163')).to eq 6
        expect(Honeybadger).not_to have_received(:notify)
        ENV['PLAUSIBLE_KEY'] = nil
      end
    end
  end
end
# rubocop:enable Layout/LineLength
