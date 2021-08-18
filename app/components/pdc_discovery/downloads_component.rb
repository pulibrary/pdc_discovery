# frozen_string_literal: true

module PdcDiscovery
  class DownloadsComponent < ::ViewComponent::Base
    def initialize(document: nil, presenter: nil, document_component: nil)
      @presenter = presenter
      @document = document || presenter&.document
      @document_component = document_component
    end

    def field_values
      # @field.values
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
  end
end
