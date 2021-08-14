# frozen_string_literal: true

module PdcDiscovery
  class DescriptionFieldComponent < MetadataFieldComponent
    with_collection_parameter :field

    def component_name
      'description'
    end
  end
end
