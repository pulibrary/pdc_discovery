# frozen_string_literal: true

class RecentlyAdded
  require 'net/http'
  require 'json'

  def self.feed(root_path)
    url = URI.join(root_path, "catalog.json").to_s
    resp = http_get(url)
    result = JSON.parse(resp.body)
    payload = {}
    result['data'].each do |entry|
      payload[entry['id']] = {
        title: entry['attributes']['title_tsim']['attributes']['value'],
        link: entry['links']['self'],
        author: entry['attributes']['author_tesim']['attributes']['value'],
        genre: entry['attributes']['genre_ssim']['attributes']['value'],
        issue_date: entry['attributes']['issue_date_ssim']['attributes']['value']
      }
    end
    payload
  rescue StandardError => ex
    Rails.logger.warn "Error fetching recently added feed: #{ex.message}."
    {}
  end

  def self.http_get(url, read_timeout: 3)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = read_timeout
    if url.start_with?("https://")
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    http.request(request)
  end
end
