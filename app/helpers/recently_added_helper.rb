module RecentlyAddedHelper

  require 'net/http'
  require 'json'

  ICONS = {
    "dataset" => "bi-stack",
    "moving image" => "bi-film",
    "software" => "bi-code-slash",
    "image" => "bi-image",
    "text" => "bi-card-text",
    "collection" => "bi-collection-fill",
    "article" => "bi-journal-text",
    "interactive resource" => "bi-pc-display-horizontal",
  }

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
    <li id="recently-added-#{entry_key}">
    <span class="genre"><i class="bi #{ICONS[entry_values[:genre].downcase].presence || "bi-file-earmark-fill"}"></i>#{html_escape(entry_values[:genre])}</span>
    <span class="title">#{link_to(html_escape(entry_values[:title]), html_escape(entry_values[:link]))}</span>
    <span class="credit">Posted on #{html_escape(entry_values[:issue_date])}, #{html_escape(entry_values[:author])}</span>
    </li>
    HTML
    html.html_safe
  end



end
