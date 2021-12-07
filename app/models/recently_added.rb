# frozen_string_literal: true

class RecentlyAdded
  require 'net/http'
  require 'json'

  def self.feed(root_path)
    url = "#{root_path}/catalog.json"
    # ==
    # Or we could also so use our custom end point
    # url = "/catalog/recently_added.json"
    # ==
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    result = JSON.parse(data)
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
  end
end
