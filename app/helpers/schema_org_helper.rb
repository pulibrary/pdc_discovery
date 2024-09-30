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
    authors_json = authors.each.map do |author|
      json_str = "\n\t\t\t{\n\t\t\t" + '"name": ' + '"' + author.value + '"'
      if author.affiliation_name.present?
        json_str += "\n\t\t\t" + '"affiliation": ' + '"' + author.affiliation_name + '"'
      end  
      if author.orcid.present?
        json_str += "\n\t\t\t" + '"identifier": ' + '"' + author.orcid + '"'
      end
      json_str += "\n\t\t\t}"
      json_str
    end
    html = "[" + authors_json.join(",") + "]"
    html.html_safe
  end

  def license_helper(licenses)
    if licenses.count == 0 
      ""
    else
      html = '"license": {'
      html += "\n\t\t\t" + '"@type:" ' + '"Dataset"' + ",\n" + 
        "\t\t\t" + '"text:" ' + '"' + licenses[0]['identifier'] + '"' + ",\n" + 
        "\t\t\t" + '"url:" ' + '"' + licenses[0]['uri'] + '"'  
      html += "\n\t\t\t},"
      html.html_safe
    end
  end
end

