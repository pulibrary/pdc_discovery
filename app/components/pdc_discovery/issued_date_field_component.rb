# frozen_string_literal: true

module PdcDiscovery
  class IssuedDateFieldComponent < MetadataFieldComponent
    with_collection_parameter :field

    def component_name
      'issued-date'
    end
  end
end
