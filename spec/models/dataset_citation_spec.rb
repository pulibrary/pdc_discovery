# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# rubocop:disable RSpec/ExampleLength
RSpec.describe DatasetCitation do
  let(:single_author_dataset) { described_class.new(["Menard, J.E."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123") }
  let(:two_authors_dataset) { described_class.new(["Menard, J.E.", "Lopez, R."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123") }
  let(:three_authors_dataset) { described_class.new(["Menard, J.E.", "Lopez, R.", "Liu, D."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123") }

  describe "#apa" do
    it "handles authors correctly" do
      expect(single_author_dataset.apa).to eq "Menard, J.E. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
      expect(two_authors_dataset.apa).to eq "Menard, J.E. & Lopez, R. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
      expect(three_authors_dataset.apa).to eq "Menard, J.E., Lopez, R., & Liu, D. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
    end
  end

  describe "#chicago" do
    it "handles authors correctly" do
      expect(single_author_dataset.chicago).to eq "Menard, J.E. Compact steady-state tokamak. 2018. Princeton University. http://doi.org/princeton/test123."
      expect(two_authors_dataset.chicago).to eq "Menard, J.E. and Lopez, R. Compact steady-state tokamak. 2018. Princeton University. http://doi.org/princeton/test123."
      expect(three_authors_dataset.chicago).to eq "Menard, J.E., Lopez, R. and Liu, D. Compact steady-state tokamak. 2018. Princeton University. http://doi.org/princeton/test123."
    end
  end

  describe "#bibtex" do
    it "returns correct format" do
      bibtex = "@electronic{ menard_je_2018,\r\n" \
      "  author = \"Menard, J.E.\",\r\n" \
      "  title = \"Compact steady-state tokamak\",\r\n" \
      "  publisher = \"Princeton University\",\r\n" \
      "  year = \"2018\",\r\n" \
      "  url = \"http://doi.org/princeton/test123\"\r\n" \
      "}"
      expect(single_author_dataset.bibtex).to eq bibtex
    end
  end

  describe "title" do
    it "does not add extra periods to title and publisher if they come in the source data" do
      citation = described_class.new(["Menard, J.E."], [2018], "Compact steady-state tokamak.", "Data set", "Princeton University.", "http://doi.org/princeton/test123")
      expect(citation.apa).to eq "Menard, J.E. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
      expect(citation.chicago).to eq "Menard, J.E. Compact steady-state tokamak. 2018. Princeton University. http://doi.org/princeton/test123."
    end
  end

  describe "year" do
    it "handles year ranges" do
      citation = described_class.new(["Menard, J.E."], [2018, 2020], "Compact steady-state tokamak.", "Data set", "Princeton University.", "http://doi.org/princeton/test123")
      expect(citation.apa).to eq "Menard, J.E. (2018-2020). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
      expect(citation.chicago).to eq "Menard, J.E. Compact steady-state tokamak. 2018-2020. Princeton University. http://doi.org/princeton/test123."
    end
  end

  describe "#custom_strip" do
    it "custom trailing characters" do
      expect(described_class.custom_strip("Some title.")).to eq "Some title"
      expect(described_class.custom_strip("Some title..")).to eq "Some title"
      expect(described_class.custom_strip("Some title")).to eq "Some title"
      expect(described_class.custom_strip("Some title, ")).to eq "Some title"
      expect(described_class.custom_strip("Some title, .")).to eq "Some title"
      expect(described_class.custom_strip("")).to eq ""
      expect(described_class.custom_strip(nil)).to eq nil
      expect(described_class.custom_strip(" . , ")).to eq ""
    end
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable Layout/LineLength
