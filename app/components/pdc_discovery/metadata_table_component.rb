# frozen_string_literal: true

module PdcDiscovery
  class MetadataTableComponent < ::ViewComponent::Base
    def initialize(document: nil, presenter: nil, document_component: nil)
      @presenter = presenter
      @document = document || presenter&.document
      @document_component = document_component
    end

    def fields
      @presenter.field_presenters
    end

    def field_values
      children = fields.map(&:values)
      children.reduce(:+)

      [
        {
          label: 'Author',
          values: ['Gartner, Thomas III', 'Zhang, Linfeng']
        }
      ]
    end

    def values_json
      JSON.generate(field_values)
    end

    def component_name
      'metadata-table'
    end

    def component_tag
      content_tag(component_name.to_sym, nil, ':values' => values_json)
    end
  end
end
