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
