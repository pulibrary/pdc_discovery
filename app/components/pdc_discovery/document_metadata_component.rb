# frozen_string_literal: true

module PdcDiscovery
  class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
    attr_reader :document

    # @param fields [Enumerable<Blacklight::FieldPresenter>] Document field presenters
    def initialize(document:, fields: [], show: false)
      @document = document
      @fields = fields
      @show = show
    end

    def before_render
      return unless fields

      @fields.each do |field|
        field(component: field_component(field), field: field, show: @show)
      end
    end

    def authors
      # @fields.select { |field| field.is_author? }
      @fields.select { |field| field.field == '' }
    end

    def authors_component
      @authors_component ||= AuthorsComponent.new(authors: authors)
    end

    def render?
      fields.present?
    end

    def field_component(field)
      field&.component || Blacklight::MetadataFieldComponent
      # field&.component || MetadataFieldComponent
    end
  end
end
