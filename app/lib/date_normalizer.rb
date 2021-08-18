# frozen_string_literal: true

##
# Given an array of Strings, parse them as dates.
class DateNormalizer
  ##
  # @param [<String>] date_strings
  # @return [<String>] An array of strings formatted for display
  def self.format_array_for_display(date_strings)
    date_strings.map { |x| format_string_for_display(x) }
  end

  def self.format_string_for_display(date_string)
    if date_string.match?(/\d\d\d\d-\d\d/)
      Date.strptime(date_string, '%Y-%m').strftime('%B %Y')
    else
      date_string
    end
  end
end
