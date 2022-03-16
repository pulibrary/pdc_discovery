# frozen_string_literal: true

require 'yaml'

module BannerHelper
  # rubocop:disable Rails/ContentTag
  def banner_content
    @yaml_data = YAML.load_file('config/banner.yml')
    return false if @yaml_data[Rails.env].nil?
    @banner_title = content_tag(:h1, @yaml_data[Rails.env]['title'])
    @banner_body = content_tag(:p, @yaml_data[Rails.env]['body'])
  end
  # rubocop:enable Rails/ContentTag
end
