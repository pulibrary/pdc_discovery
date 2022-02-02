# frozen_string_literal: true

class License
  def self.url(license_type)
    case normalize_type(license_type)
    when 'cc0 license'
      'https://creativecommons.org/publicdomain/zero/1.0/'
    end
  end

  def self.normalize_type(license_type)
    return nil if license_type.nil?
    license_type.downcase.strip
  end
end
