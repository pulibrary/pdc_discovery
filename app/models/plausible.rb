# frozen_string_literal: true
require 'plausible_api'

class Plausible
  def self.page_views(document_id)
    # byebug
    # return 'X' unless Rails.env.staging? || Rails.env.production?

    c = PlausibleApi::Client.new(Rails.configuration.pdc_discovery.plausible_site_id, (ENV['PLAUSIBLE_KEY'] || ''))
    response = c.aggregate({ date: "2021-01-01,#{Time.zone.today.strftime('%Y-%m-%d')}", metrics: 'visitors,pageviews', filters: "event:page==/catalog/#{document_id}" })
    response["pageviews"]["value"]
  rescue => e
    logger.error "PLAUSIBLE ERROR: (Document: #{document_id}) #{e.message}"
    Honeybadger.notify(e.message)
    '0'
  end

  def self.downloads(document_id)
  end
end
