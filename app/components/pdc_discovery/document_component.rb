# frozen_string_literal: true

module PdcDiscovery
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :downloads, (lambda do |*args, component: nil, **kwargs|
      component ||= DownloadsComponent

      component.new(*args,
                    document: @document,
                    presenter: @presenter,
                    document_component: self,
                    **kwargs)
    end)

    renders_one :metadata_table, (lambda do |*args, component: nil, **kwargs|
      component ||= MetadataTableComponent

      # Fields are accessed using presenter.field_presenters
      component.new(*args,
                    document: @document,
                    presenter: @presenter,
                    document_component: self,
                    **kwargs)
    end)

    def downloads_component
      @downloads_component ||= DownloadsComponent
    end

    def metadata_table_component
      @metadata_table_component ||= MetadataTableComponent
    end

    def document_metadata_component
      @document_metadata_component ||= DocumentMetadataComponent
    end

    def before_render
      super

      set_slot(:metadata, component: document_metadata_component, fields: presenter.field_presenters)
      set_slot(:downloads, component: downloads_component)
      set_slot(:metadata_table, component: metadata_table_component)
    end
  end
end
