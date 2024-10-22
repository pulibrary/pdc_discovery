# frozen_string_literal: true

require 'rails_helper'
RSpec.describe SchemaOrgHelper, type: :helper do
  let(:author_with_orcid) do
    {
      "value" => "some_name",
      "identifier" => {
        "scheme" => "ORCID",
        "value" => "0000-0000-1111-1111"
      },
      "affiliations" => [
        { "value" => "some_affiliation" }
      ]
    }
  end

  let(:author_without_orcid) do
    {
      "value" => "some_name"
    }
  end

  let(:license) do
    {
      "identifier" => "some_identifier",
      "uri" => "some_uri"
    }
  end

  describe "#render_sidebar_related_identifiers" do
    it "renders keywords" do
      expect(helper.keywords_helper(['a', 'b'])).to eq '["a","b"]'
    end

    it "does not render keywords" do
      expect(helper.keywords_helper([])).to eq '[]'
    end

    it "renders authors with orcid and affiliation" do
      author = [Author.new(author_with_orcid)]
      # Expected output with orcid and affiliation
      expected_output = "[\n\t\t\t{\n\t\t\t\"name\": \"some_name\",\n\t\t\t\"affiliation\": \"some_affiliation\",\n\t\t\t\"identifier\": \"0000-0000-1111-1111\"\n\t\t\t}]"

      # Call the helper function with the authors array and verify the result
      expect(helper.authors_helper(author)).to eq expected_output
    end

    it "renders authors without orcid nor affiliation" do
      author = [Author.new(author_without_orcid)]
      # Expected output without orcid and affiliation
      expected_output = "[\n\t\t\t{\n\t\t\t\"name\": \"some_name\"\n\t\t\t}]"

      # Call the helper function with the authors array and verify the result
      expect(helper.authors_helper(author)).to eq expected_output
    end

    it "render one license" do
      expected_output = "\"license\": {\n\t\t\t\"@type\": \"Dataset\",\n\t\t\t\"text\": \"some_identifier\",\n\t\t\t\"url\": \"some_uri\"\n\t\t\t},"
      expect(helper.license_helper([license])).to eq expected_output
    end

    it "renders no license" do
      expect(helper.license_helper([])).to eq ""
    end
  end
end
