module RecentlyAddedHelper

  require 'net/http'
  require 'json'

  def fetch_feed(url)
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    result = JSON.parse(data)
    payload = {}
    result['data'].each do |entry|
      payload[entry['id']] = {
        :title => entry['attributes']['title_tsim']['attributes']['value'],
        :link => entry['links']['self'],
        :author => entry['attributes']['author_tesim']['attributes']['value'],
        :genre => entry['attributes']['genre_ssim']['attributes']['value'],
        :issue_date => entry['attributes']['issue_date_ssim']['attributes']['value']
      }
    end

    return payload

  end

  def render_recent_entry(entry_key, entry_values, render_empty: false)
    return if entry_values.empty?
    html = <<-HTML
    <li class="recently-added" id="recently-added-#{entry_key}">
    <span class="genre icon-#{entry_values[:genre].downcase}">#{html_escape(entry_values[:genre])}</span>
    <span class="title">#{html_escape(entry_values[:title])}</span>
    <span class="author">#{html_escape(entry_values[:author])}</span>
    <span class="issue_date">#{html_escape(entry_values[:issue_date])}</span>
    </li>
    HTML
    html.html_safe
  end



end
