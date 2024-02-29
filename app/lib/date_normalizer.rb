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

  def self.strict_dates(date_strings)
    date_strings.map { |date| strict_date(date) }.compact.sort
  end

  # Returns the date in yyyy-mm-dd format. If there is no day or month it defaults
  # to day 01, month 01.
  def self.strict_date(date_string)
    return nil if date_string.nil?
    if date_string.match?(/\d{4}-\d{1,2}-\d{1,2}/)
      Date.strptime(date_string).strftime('%Y-%m-%d')
    elsif date_string.match?(/\d{4}-\d{1,2}/)
      Date.strptime(date_string, '%Y-%m').strftime('%Y-%m-%d')
    elsif date_string.match?(/\d{4}/)
      date_string + "-01-01"
    end
  rescue ArgumentError
    # bad formatted date
    nil
  end

  def self.years_from_dates(date_strings)
    date_strings.map { |date| year_from_date(date) }.compact
  end

  def self.year_from_date(date_string)
    if date_string.match?(/\d{4}-\d{2}-\d{2}/)
      Date.strptime(date_string).strftime('%Y').to_i
    elsif date_string.match?(/\d{4}-\d{2}/)
      Date.strptime(date_string, '%Y-%m').strftime('%Y').to_i
    elsif date_string.match?(/^\d{4}/) && date_string.size == 4
      date_string.to_i
    else
      time = Time.zone.parse(date_string)
      time.year
    end
  rescue ArgumentError
    # bad formatted date
    Rails.logger.warn("Error parsing date #{date_string}")
    nil
  end
end
