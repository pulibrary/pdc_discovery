# frozen_string_literal: true

module PdcDiscovery
  class AbstractFieldComponent < MetadataFieldComponent
    with_collection_parameter :field

    def component_name
      'abstract'
    end
  end
end
