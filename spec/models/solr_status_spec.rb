# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
# rubocop:disable RSpec/ExampleLength
RSpec.describe SolrStatus do
  describe "#check!" do
    it "checks solr status" do
      doc = described_class.new
      expect { doc.check! }.not_to raise_error
    end
  end
end
