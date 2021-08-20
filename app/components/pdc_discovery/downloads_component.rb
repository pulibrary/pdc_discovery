# frozen_string_literal: true

module PdcDiscovery
  class DownloadsComponent < ::ViewComponent::Base
    def initialize(document: nil, presenter: nil, document_component: nil)
      @presenter = presenter
      @document = document || presenter&.document
      @document_component = document_component
    end

    def field_values
      # This is for the demo.
      [
        {
          fileName: {
            href: '',
            content: 'file1.csv'
          },
          fileSize: '10KB'
        },
        {
          fileName: {
            href: '',
            content: 'File2.xml'
          },
          fileSize: '15kb'
        }
      ]
    end

    def values_json
      JSON.generate(field_values)
    end

    def component_name
      'downloads'
    end

    def component_tag
      content_tag(component_name.to_sym, nil, ':values' => values_json)
    end
  end
end
