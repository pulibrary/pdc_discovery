# frozen_string_literal: true
module SchemaOrgHelper
  def keywords_helper(subjects)
    html = "["
    subjects.each_with_index do |subject, i|
      if i < (subjects.count-1)
        html += '"' + html_escape(subject) + '", '
      else
        html += '"' + html_escape(subject) + '"'
      end
    end

    html += "]"
    html.html_safe
  end
end

  def authors_helper(authors)
    html = "["
    authors.each_with_index do |author, i|
      if i < (authors.count-1)
        html += '{<br>"name": ' + html_escape(author.value) + '<br>'
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


  # "name": "<%= author.value %>"
  #             "affiliation": "<%= author.affiliation_name%>"
  #             "identifier": "<%= author.orcid%>"

# "keywords":
# [
#   <% @document.subject.each_with_index do |subject, i| %>
#     <% if i < (@document.subject.count-1) %>
#       "<%= subject %>",
#     <% else %>
#       "<%= subject %>"
#     <% end %>
#   <% end%>
# ],
