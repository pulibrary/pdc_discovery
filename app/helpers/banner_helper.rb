# frozen_string_literal: true

require 'yaml'

module BannerHelper
  def banner_content
    @yaml_data = YAML.load_file('config/banner.yml')
    return false if @yaml_data.nil? || @yaml_data[Rails.env].nil?

    title = @yaml_data[Rails.env]['title']
    body = @yaml_data[Rails.env]['body']
    return false if title.nil? && body.nil?

    @banner_title = "<h1>#{title}</h1>"
    @banner_body = "<p>#{body}</p>"
  end
end
