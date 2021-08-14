# frozen_string_literal: true

module PdcDiscovery
  class MethodFieldComponent < MetadataFieldComponent
    with_collection_parameter :field

    def component_name
      'method'
    end
  end
end
