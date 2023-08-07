# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author do
  describe "#affiliation_name" do
    # Use => in this hash to force RSpec to use strings in the keys (rather than symbols) since the source
    # data always uses strings
    let(:author_no_affiliation) { { "value" => "Smith, Jane", "given_name" => "Jane", "family_name" => "Smith" } }
    let(:author_with_affiliation) do
      {
        "value" => "Smith, Jane",
        "given_name" => "Jane",
        "family_name" => "Smith",
        "affiliations" => [{ "value" => "Princeton Plasma Physics Laboratory", "identifier" => "https://ror.org/03vn1ts68",
                             "scheme" => "ROR" }]
      }
    end

    it "handles affiliation information" do
      author = described_class.new(author_no_affiliation)
      expect(author.affiliation_name).to be nil

      author = described_class.new(author_with_affiliation)
      expect(author.affiliation_name).to eq "Princeton Plasma Physics Laboratory"
    end
  end
end
