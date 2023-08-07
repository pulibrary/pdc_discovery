# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author do
  describe "#affiliation_name" do
    let (:author_zero_affiliations) { { "value": "Smith, Jane", "given_name": "Jane", "family_name": "Smith" } }
    it "x" do
      author = described_class.new(author_zero_affiliations)
      expect(doc.affiliation_name).to be nil
    end
  end
end
