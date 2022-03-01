# frozen_string_literal: true
require 'plausible_api'

class Plausible
  PLAUSIBLE_URL = 'https://plausible.io/api/v1'

  def self.page_views(document_id)
    # byebug
    # return 'X' unless Rails.env.staging? || Rails.env.production?
    c = PlausibleApi::Client.new(Rails.configuration.pdc_discovery.plausible_site_id, (ENV['PLAUSIBLE_KEY'] || ''))
    response = c.aggregate({ date: "2021-01-01,#{Time.zone.today.strftime('%Y-%m-%d')}", metrics: 'visitors,pageviews', filters: "event:page==/catalog/#{document_id}" })
    response["pageviews"]["value"]
  rescue => e
    Rails.logger.error "PLAUSIBLE ERROR: (Pageviews for document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    '0'
  end

  def self.downloads(document_id)
    site_id = Rails.configuration.pdc_discovery.plausible_site_id
    period = "7d"
    page = "/catalog/#{document_id}"
    url = "#{PLAUSIBLE_URL}/stats/breakdown?site_id=#{site_id}&period=#{period}&property=event:props:filename&filters=event:page==#{page}&metrics=visitors,pageviews"
    authorization = "Bearer #{ENV['PLAUSIBLE_KEY']}"
    response = HTTParty.get(sub_community_url, headers: { 'Authorization' => authorization})
    Rails.logger.info response.to_s
    '123'
  rescue => e
    Rails.logger.error "PLAUSIBLE ERROR: (Downloads for document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    '0'
  end
end
