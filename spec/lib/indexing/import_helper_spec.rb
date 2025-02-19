# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Indexing::ImportHelper do
  describe "#globus_folder_uri_from_file" do
    it "returns the URI with the origin and path parameters" do
      globus_folder_uri = described_class.globus_folder_uri_from_file("10.123/4567/40/file1.txt")
      expect(globus_folder_uri.include?("origin_id=xxxx-yyyy-zzzz-aaaa-bbbb")).to be true
      expect(globus_folder_uri.include?("origin_path=%2F10.123%2F4567%2F40%2F")).to be true
    end
  end

  describe ".pdc_describe_match_by_uri?" do
    let(:solr_url) { "https://localhost:8080/solr" }
    let(:uri) { "https://test.net" }
    let(:result) { described_class.pdc_describe_match_by_uri?(solr_url, uri) }
    let(:logger) { instance_double(ActiveSupport::Logger) }

    before do
      allow(logger).to receive(:error)
      allow(Rails).to receive(:logger).and_return(logger)
      allow(Honeybadger).to receive(:notify)
      allow(HTTParty).to receive(:get).and_raise(Errno::ECONNREFUSED)
    end

    it "logs an error, notifies Honeybadger, and returns false" do
      expect(result).to be false
      solr_query = "https://localhost:8080/solr/select?q=data_source_ssi:pdc_describe+AND+uri_ssim:\"https://test.net\""
      expect(logger).to have_received(:error).with("HTTP GET request failed for #{solr_query}: Connection refused")
      expect(Honeybadger).to have_received(:notify).with("HTTP GET request failed for #{solr_query}: Connection refused")
    end
  end
end
