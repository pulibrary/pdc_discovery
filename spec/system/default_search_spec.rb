# frozen_string_literal: true
require 'rails_helper'

describe "Default search", type: :system do
  context "indexing all text" do
    before do
      solr_delete_all!
      xml = file_fixture("single_item.xml").read
      indexer = DspaceIndexer.new(xml)
      indexer.index
      Blacklight.default_index.connection.commit
    end

    it "finds value only indexed in catch all field." do
      num_docs = solr_num_documents({ q: 'Stotler_PoP.zip' })
      expect(num_docs).to eq 1

      num_docs = solr_num_documents({ q: 'not-existing-file.txt' })
      expect(num_docs).to eq 0
    end
  end
end
