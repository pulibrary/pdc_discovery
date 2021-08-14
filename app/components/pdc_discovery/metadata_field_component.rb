# frozen_string_literal: true

module PdcDiscovery
  class MetadataFieldComponent < Blacklight::MetadataFieldComponent
    def field_values
      @field.values
    end

    def values_json
      JSON.generate(@field.values)
    end

    def field_value
      field_values.first
    end

    def component_name
      'div'
    end

    def component_tag
      content_tag(component_name.to_sym, nil, ':values' => values_json)
    end
  end
end
