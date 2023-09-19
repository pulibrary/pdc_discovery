# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety
# rubocop:disable Metrics/ModuleLength
module ApplicationHelper
  # This application is deployed in a subdirectory ("/discovery")
  # in staging and production. We control this by setting
  # Rails.application.config.assets.prefix. This method reads
  # that Rails setting and extracts the prefix needed in order for
  # application links to work as expected.
  # @return [String]
  def subdirectory_for_links
    (Rails.application.config.assets.prefix.split("/") - ["assets"]).join("/")
  end

  # Outputs the HTML to render a single value as an HTML table row
  # to be displayed on the metadata section of the show page.
  def render_field_row(title, value, show_always = false)
    return if value.nil?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{html_escape(value)}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render multiple values as an HTML table row
  def render_field_row_many(title, values, show_always = false, separator = ', ')
    return if values.blank?
    values_encoded = values.map { |v| html_escape(v) }
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title.pluralize(values.count)}</span></th>
      <td><span>#{values_encoded.join(separator)}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render multiple authors and their affiliations as an HTML table row
  def render_authors_many(title, authors)
    return if authors.empty?
    authors_encoded = authors.map do |author|
      text = author.value
      text += " (#{author.affiliation_name})" if author.affiliation_name
      html_escape(text)
    end
    html = <<-HTML
    <tr>
      <th scope="row"><span>#{title.pluralize(authors.count)}</span></th>
      <td><span>#{authors_encoded.join('<br/>')}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row with a link
  def render_field_row_link(title, url, show_always = false)
    return if url.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(url, url, target: '_blank', rel: 'noopener noreferrer')}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Returns a search link to search by a facet field
  def search_link(value, facet_field)
    "#{subdirectory_for_links}/?f[#{facet_field}][]=#{CGI.escape(value)}&q=&search_field=all_fields"
  end

  # Returns a search link to search by a specific field
  def search_link_by_field(value, field = "")
    "#{subdirectory_for_links}/?&q=#{CGI.escape(value)}&search_field=#{field}"
  end

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_link(title, value, field, show_always = false)
    return if value.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title}</span></th>
      <td><span>#{link_to(value, search_link(value, field))}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  # Outputs the HTML to render a single value as an HTML table row with a search link
  def render_field_row_search_links(title, values, field, show_always = false)
    return if values.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    links = values.map do |value|
      "<span>" + link_to(value, search_link(value, field)) + "</span>"
    end
    html = <<-HTML
    <tr class="#{css_class}">
      <th scope="row"><span>#{title.pluralize(values.count)}</span></th>
      <td>#{links.join(', ')}</td>
    </tr>
    HTML
    html.html_safe
  end

  # Renders citation information APA-ish and BibTeX.
  # Notice that the only the APA style is visible, the BibTeX citataion is enabled via JavaScript.
  def render_cite_as(document)
    return if document.cite("APA").nil?

    apa = document.cite("APA")
    bibtex = document.cite("BibTeX")
    bibtex_html = html_escape(bibtex).gsub("\r\n", "<br/>").gsub("\t", "  ").gsub("  ", "&nbsp;&nbsp;")
    bibtex_text = html_escape(bibtex).gsub("\t", "  ")

    html = <<-HTML
      <div class="citation-apa-container">
        <div class="apa-citation">#{html_escape(apa)}</div>
        <button id="copy-apa-citation-button" class="copy-citation-button btn btn-sm" data-style="APA" data-text="#{html_escape(apa)}" title="Copy citation to the clipboard">
          <i class="bi bi-clipboard" title="Copy citation to the clipboard"></i>
          <span class="copy-citation-label-normal">COPY</span>
        </button>
      </div>
      <div class="citation-bibtex-container hidden-element">
        <div class="bibtex-citation">#{bibtex_html}</div>
        <button id="copy-bibtext-citation-button" class="copy-citation-button btn btn-sm" data-style="BibTeX" data-text="#{bibtex_text}" title="Copy BibTeX citation to the clipboard">
          <i class="bi bi-clipboard" title="Copy BibTeX citation to the clipboard"></i>
          <span class="copy-citation-label-normal">COPY</span>
        </button>
        <button id="download-bibtex" class="btn btn-sm" data-url="#{catalog_bibtex_url(id: document.id)}" title="Download BibTeX citation to a file">
          <i class="bi bi-file-arrow-down" title="Download BibTeX citation to a file"></i>
          <span class="copy-citation-label-normal">DOWNLOAD</span>
        </button>
      </div>
    HTML
    html.html_safe
  end

  def render_globus_download(uri, item_id)
    return if uri.nil?
    # The `globus-download-link` CSS class is used to track download clicks in Plausible
    html = <<-HTML
    <div id="globus">
      <a href="#{uri}" title="Opens in a new tab" class="btn globus_button globus-download-link"
        target="_blank" rel="noopener noreferrer" data-item-id="#{item_id}">
        #{image_tag('globus_logo.png', width: '20', alt: 'Globus logo')} Download from Globus
      </a>
    </div>
    HTML
    html.html_safe
  end

  def render_empty_files
    html = <<-HTML
    <div id="no_files">
    </div>
    HTML
    html.html_safe
  end

  def authors_search_results_helper(field)
    field[:document].authors_ordered.map(&:value).join("; ")
  end

  # Produces the HTML to render a single author and accounts for ORCID and Affiliation information
  def render_author(author, add_separator)
    name = author.value
    return if name.blank?

    separator = add_separator ? ";" : ""
    tooltip_html = author_tooltip_html(author)
    author_html = if tooltip_html.strip == ""
                    "#{name}#{separator}"
                  else
                    # For popover options
                    # see https://getbootstrap.com/docs/4.6/components/popovers/
                    <<-HTML
                      <a tabindex="0"
                        title="#{name}"
                        data-toggle="popover"
                        data-html="true"
                        data-placement="bottom"
                        data-content="#{tooltip_html}"
                        data-trigger="focus"
                        class="author_popover_link">#{name}
                      </a>#{separator}
                    HTML
                  end

    html = "<span class=\"author-name\">#{author_html}</span>"
    html.html_safe
  end

  # Returns the HTML for the author tooltip combining whatever information
  # we have available for the author (e.g. ORCID, Affiliation).
  def author_tooltip_html(author)
    orcid = author.identifier&.dig("value") if author.identifier&.dig("scheme")&.upcase == "ORCID"

    orcid_html = ""
    if orcid
      orcid_html = <<-HTML
        <img alt='ORCID logo' src='https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png' width='16' height='16' />
        ORCID: <a href='https://orcid.org/#{orcid}' target=_blank>#{orcid}</a><br/>
        Find other works <a href='#{search_link_by_field(orcid)}'>by this author</a> in PDC Discovery.<br/>
      HTML
    end

    affiliation_html = ""
    if author.affiliation_name
      affiliation_link = search_link(author.affiliation_name, "authors_affiliation_ssim")
      affiliation_html = <<-HTML
        <a href='#{affiliation_link}'>#{author.affiliation_name}</a><br/>
      HTML
    end

    "#{orcid_html}#{affiliation_html}"
  end

  # Produces the HTML to render the affiliations for a group of authors
  def render_author_affiliations(authors)
    affiliations = authors.map { |author| author.affiliation_index > 0 ? author.affiliation : nil }.compact

    affiliations_html = affiliations.map do |affiliation|
      "<span class='author-name'><sup>#{affiliation['index']}</sup> #{affiliation['value']}</span>"
    end.uniq

    html = <<-HTML
    <div class="author-affiliations">
      #{affiliations_html.join(', ')}
    </span>
    HTML
    html.html_safe
  end

  def render_funders(funders)
    return if funders.count == 0

    funders_html = funders.map { |funder| render_funder(funder) }

    html = <<-HTML
    <tr class="toggable-row hidden-row">
      <th scope="row"><span>Funders</span></th>
      <td><span>#{funders_html.join("<br/>")}</span></td>
    </tr>
    HTML
    html.html_safe
  end

  def render_funder(funder)
    funder_name = ""
    if funder['ror']
      funder_name = link_to(funder['name'], search_link(funder['name'], funder['ror']))
    else
      funder_name = funder['name']
    end

    funder_award = ""
    if !funder['award_uri'].blank?
      funder_award = link_to(funder['award_number'], funder['award_uri'])
    elsif !funder['award_number'].blank?
      funder_award = funder['award_number']
    end

    if funder_award.blank?
      funder_name
    else
      funder_name + ", " + funder_award
    end
  end
end
# rubocop:enable Rails/OutputSafety
# rubocop:enable Metrics/ModuleLength
