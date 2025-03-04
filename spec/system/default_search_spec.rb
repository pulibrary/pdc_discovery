# frozen_string_literal: true
require 'rails_helper'

describe "Default search", type: :system do
  context "indexing all text" do
    before do
      load_describe_small_data
    end

    it "finds value only indexed in catch all field." do
      num_docs = solr_num_documents({ q: 'file3.txt' })
      expect(num_docs).to eq 1

      num_docs = solr_num_documents({ q: 'not-existing-file.txt' })
      expect(num_docs).to eq 0
    end
  end
end
