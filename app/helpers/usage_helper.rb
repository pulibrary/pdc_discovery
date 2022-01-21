# frozen_string_literal: true
require 'plausible_api'
module UsageHelper
  def downloads(files)
    files.map(&:downloads).inject(0, :+).to_s
  end

  def views
    c = PlausibleApi::Client.new('pdc-discovery-staging.princeton.edu', (ENV['PLAUSIBLE_KEY'] || ''))
    c.aggregate({ date: "2021-01-01,#{Date.today.strftime("%Y-%m-%d")}", metrics: 'visitors,pageviews', filters: "event:page==/catalog/#{@document.id}"})["pageviews"]["value"]
  rescue => e
    logger.error "PLAUSIBLE ERROR: #{e.message}"
    '0'
  end

end
