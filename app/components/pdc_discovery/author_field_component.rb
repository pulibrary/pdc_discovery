# frozen_string_literal: true

module PdcDiscovery
  class AuthorFieldComponent < MetadataFieldComponent
    with_collection_parameter :field

    def component_name
      'authors'
    end
  end
end
