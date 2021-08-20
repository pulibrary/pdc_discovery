# frozen_string_literal: true

module PdcDiscovery
  class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
    def self.find_field_component(key:)
      case key
      when SolrDocument::ABSTRACT_FIELD
        AbstractFieldComponent
      when SolrDocument::AUTHOR_FIELD
        AuthorFieldComponent
      when SolrDocument::DESCRIPTION_FIELD
        DescriptionFieldComponent
      when SolrDocument::ISSUED_DATE_FIELD
        IssuedDateFieldComponent
      when SolrDocument::METHODS_FIELD
        MethodFieldComponent
      else
        MetadataFieldComponent
      end
    end

    def find_fields(key:)
      @fields.select { |field| field.key == key }
    end

    # Abstracts
    def abstracts
      field_component_class = self.class.find_field_component(key: SolrDocument::ABSTRACT_FIELD)
      component_fields = find_fields(key: SolrDocument::ABSTRACT_FIELD)

      field_component_class.with_collection(component_fields, show: @show)
    end

    # Authors
    def authors
      field_component_class = self.class.find_field_component(key: SolrDocument::AUTHOR_FIELD)
      component_fields = find_fields(key: SolrDocument::AUTHOR_FIELD)

      field_component_class.with_collection(component_fields, show: @show)
    end

    # Descriptions
    def descriptions
      field_component_class = self.class.find_field_component(key: SolrDocument::DESCRIPTION_FIELD)
      component_fields = find_fields(key: SolrDocument::DESCRIPTION_FIELD)

      field_component_class.with_collection(component_fields, show: @show)
    end

    # Issued Dates
    def issued_dates
      field_component_class = self.class.find_field_component(key: SolrDocument::ISSUED_DATE_FIELD)
      component_fields = find_fields(key: SolrDocument::ISSUED_DATE_FIELD)

      field_component_class.with_collection(component_fields, show: @show)
    end

    # Methods
    def methods
      field_component_class = self.class.find_field_component(key: SolrDocument::METHODS_FIELD)
      component_fields = find_fields(key: SolrDocument::METHODS_FIELD)

      field_component_class.with_collection(component_fields, show: @show)
    end
  end
end
