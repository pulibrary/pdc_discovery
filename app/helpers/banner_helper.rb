# frozen_string_literal: true

require 'yaml'

module BannerHelper
  # rubocop:disable Rails/ContentTag
  def banner_content
    @yaml_data = YAML.load_file('config/banner.yml')
    return false if @yaml_data.nil? || @yaml_data[Rails.env].nil?
    @banner_title = "<h1>#{@yaml_data[Rails.env]['title']}</h1>"
    @banner_body = "<p>#{@yaml_data[Rails.env]['body']}</p>"
  end
  # rubocop:enable Rails/ContentTag
end
