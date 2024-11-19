# frozen_string_literal: true
require 'plausible_api'

class Plausible
  PLAUSIBLE_API_URL = 'https://plausible.io/api/v1'

  def self.date_period
    "2021-01-01,#{Time.zone.today.strftime('%Y-%m-%d')}"
  end

  # Fetches pageview counts from Plausible for a given document id.
  def self.pageviews(document_id)
    return 'X' if ENV['PLAUSIBLE_KEY'].nil?

    c = PlausibleApi::Client.new(Rails.configuration.pdc_discovery.plausible_site_id, ENV['PLAUSIBLE_KEY'])
    page = "/discovery/catalog/#{document_id}"
    response = c.aggregate({ date: date_period, metrics: 'visitors,pageviews', filters: "event:page==#{page}" })
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

    # Plausible API breakdown API: https://plausible.io/docs/stats-api#get-apiv1statsbreakdown
    # Notice that the Plausible API uses "==" to filter: https://plausible.io/docs/stats-api#filtering
    # Time periods: https://plausible.io/docs/stats-api#time-periods
    site_id = Rails.configuration.pdc_discovery.plausible_site_id
    property = "event:props:filename"
    page = "/discovery/catalog/#{document_id}"
    filters = "event:page==#{page}"
    metrics = "visitors,pageviews"
    period = "custom"
    url = "#{PLAUSIBLE_API_URL}/stats/breakdown?site_id=#{site_id}&property=#{property}&filters=#{filters}&metrics=#{metrics}&period=#{period}&date=#{date_period}"
    authorization = "Bearer #{ENV['PLAUSIBLE_KEY']}"
    response = HTTParty.get(url, headers: { 'Authorization' => authorization })

    # retry if the response is an error
    if response.code != 200
      Rails.logger.error "PLAUSIBLE ERROR: #{response}"
      sleep(1.0)
      response = HTTParty.get(url, headers: { 'Authorization' => authorization })
    end

    total_downloads = 0

    # retry if the response is an error
    if response.code != 200
      Rails.logger.error "PLAUSIBLE ERROR after retry: #{response}"
    else
      response["results"].each do |result|
        next if result["filename"] == "(none)" # Skip old test data
        total_downloads += result["visitors"]
      end
    end

    total_downloads
  rescue => e
    Rails.logger.error "PLAUSIBLE ERROR: (Downloads for document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    0
  end
end
