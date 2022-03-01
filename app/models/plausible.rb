# frozen_string_literal: true
require 'plausible_api'

class Plausible
  PLAUSIBLE_API_URL = 'https://plausible.io/api/v1'

  # Fetches pageview counts from Plausible for a given document id.
  def self.pageviews(document_id)
    return 'X' if ENV['PLAUSIBLE_KEY'].nil?

    c = PlausibleApi::Client.new(Rails.configuration.pdc_discovery.plausible_site_id, ENV['PLAUSIBLE_KEY'])
    response = c.aggregate({ date: "2021-01-01,#{Time.zone.today.strftime('%Y-%m-%d')}", metrics: 'visitors,pageviews', filters: "event:page==/catalog/#{document_id}" })
    response["pageviews"]["value"]
  rescue => e
    Rails.logger.error "PLAUSIBLE ERROR: (Pageviews for document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    0
  end

  # Fetches download counts from Plausible for a given document id.
  #
  # We store downloads by file name for each document id (page=/catalog/123). We also store downloads from
  # Globus in a reserved filename ("globus-download") as part of this data.
  #
  # This method fetches the breakdown for all downloads by file name for a given document_id and aggregates them.
  # We could provide stats by individual file and/or for specific time periods (e.g. period=6mo) in the future.
  #
  # Notice that this methods goes straight to the Plausible API (without using the PlausbleApi gem)
  # because the gem does not support yet the ability to fetch this kind of information.
  def self.downloads(document_id)
    return 'X' if ENV['PLAUSIBLE_KEY'].nil?

    site_id = Rails.configuration.pdc_discovery.plausible_site_id
    page = "/catalog/#{document_id}"
    url = "#{PLAUSIBLE_API_URL}/stats/breakdown?site_id=#{site_id}&property=event:props:filename&filters=event:page==#{page}&metrics=visitors,pageviews"
    authorization = "Bearer #{ENV['PLAUSIBLE_KEY']}"
    response = HTTParty.get(url, headers: { 'Authorization' => authorization })
    total_downloads = 0
    response["results"].each do |result|
      next if result["filename"] == "(none)" # Skip old test data
      total_downloads += result["visitors"]
    end
    total_downloads
  rescue => e
    Rails.logger.error "PLAUSIBLE ERROR: (Downloads for document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    0
  end
end
