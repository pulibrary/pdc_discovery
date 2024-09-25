# frozen_string_literal: true
module SchemaOrgHelper
  def keywords_helper(subjects)
    keywords_json = subjects.map do |subject|
      '"' + html_escape(subject) + '"'
    end

    html = "[" + keywords_json.join(",") + "]"
    html.html_safe
  end

  def authors_helper(authors)
    html = "["
    # TODO: Add logic for affiliation or identifier not being in the author
    authors.each_with_index do |author, i|
      if i < (authors.count-1)
        html += "{\r\n \"name\": " + html_escape(author.value) + "\r\n"
        html += '"affiliation": ' + html_escape(author.affiliation_name) + '<br>'
        html += '"identifier": ' + html_escape(author.orcid) + '<br>'
        html += '},'
      else
        html += '{<br>"name": ' + html_escape(author.value) + '<br>'
        html += '"affiliation": ' + html_escape(author.affiliation_name) + '<br>'
        html += '"identifier": ' + html_escape(author.orcid) + '<br>'
        html += '}'
      end
    end
    html += "]"
    html.html_safe
  end
end

