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
    if date_string.match?(/\d{4}-\d{2}-\d{2}/)
      Date.strptime(date_string).strftime('%e %B %Y').strip
    elsif date_string.match?(/\d{4}-\d{2}/)
      Date.strptime(date_string, '%Y-%m').strftime('%B %Y')
    else
      date_string
    end
  end

  def self.years_from_dates(date_strings)
    date_strings.map { |x| years_from_date(x) }.compact
  end

  def self.years_from_date(date_string)
    if date_string.match?(/\d{4}-\d{2}-\d{2}/)
      Date.strptime(date_string).strftime('%Y').to_i
    elsif date_string.match?(/\d{4}-\d{2}/)
      Date.strptime(date_string, '%Y-%m').strftime('%Y').to_i
    else
      date_string.to_i
    end
  rescue ArgumentError
    # bad formatted date
    nil
  end
end
