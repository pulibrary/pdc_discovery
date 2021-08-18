# frozen_string_literal: true

module PdcDiscovery
  class MetadataTableComponent < ::ViewComponent::Base
    def initialize(document: nil, presenter: nil, document_component: nil)
      @presenter = presenter
      @document = document || presenter&.document
      @document_component = document_component
    end
  end
end
