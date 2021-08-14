# frozen_string_literal: true

module PdcDiscovery
  class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
    # Abstracts
    def abstract_fields
      @fields.select { |field| field.key == SolrDocument::ABSTRACT_FIELD }
    end

    def abstracts
      AbstractFieldComponent.with_collection(abstract_fields, show: @show)
    end

    # Authors
    def author_fields
      @fields.select { |field| field.key == SolrDocument::AUTHOR_FIELD }
    end

    def authors
      AuthorFieldComponent.with_collection(author_fields, show: @show)
    end

    # Descriptions
    def description_fields
      @fields.select { |field| field.key == SolrDocument::DESCRIPTION_FIELD }
    end

    def descriptions
      DescriptionFieldComponent.with_collection(description_fields, show: @show)
    end

    # Issued Dates
    def issued_date_fields
      @fields.select { |field| field.key == SolrDocument::ISSUED_DATE_FIELD }
    end

    def issued_dates
      IssuedDateFieldComponent.with_collection(issued_date_fields, show: @show)
    end

    # Methods
    def method_fields
      @fields.select { |field| field.key == SolrDocument::METHODS_FIELD }
    end

    def methods
      MethodFieldComponent.with_collection(method_fields, show: @show)
    end
  end
end
