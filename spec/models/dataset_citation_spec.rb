# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# rubocop:disable RSpec/ExampleLength
RSpec.describe DatasetCitation do
  let(:single_author_dataset) { described_class.new(["Menard, J.E."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123", 1) }
  let(:two_authors_dataset) { described_class.new(["Menard, J.E.", "Lopez, R."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123", "")}
  let(:three_authors_dataset) { described_class.new(["Menard, J.E.", "Lopez, R.", "Liu, D."], [2018], "Compact steady-state tokamak", "Data set", "Princeton University", "http://doi.org/princeton/test123", nil) }

  describe "#apa" do
    it "handles authors correctly" do
      expect(single_author_dataset.apa).to eq "Menard, J.E. (2018). Compact steady-state tokamak [Data set]. Version 1. Princeton University. http://doi.org/princeton/test123"
      expect(two_authors_dataset.apa).to eq "Menard, J.E. & Lopez, R. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
      expect(three_authors_dataset.apa).to eq "Menard, J.E., Lopez, R., & Liu, D. (2018). Compact steady-state tokamak [Data set]. Princeton University. http://doi.org/princeton/test123"
    end
  end

  describe "#bibtex" do
    it "returns correct format" do
      bibtex = "@electronic{menard_je_2018,\r\n" \
      "\tauthor      = {Menard, J.E.},\r\n" \
      "\ttitle       = {{Compact steady-state tokamak}},\r\n" \
      "\tversion     = 1,\r\n" \
      "\tpublisher   = {{Princeton University}},\r\n" \
      "\tyear        = 2018,\r\n" \
      "\turl         = {http://doi.org/princeton/test123}\r\n" \
      "}"
      expect(single_author_dataset.bibtex).to eq bibtex
    end
  end

  describe "#coins" do
    it "returns correct format" do
      coins = '<span class="Z3988" title="url_ver=Z39.88-2004&amp;ctx_ver=Z39.88-2004&amp;rft.type=webpage&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;' \
      'rft.title=Compact+steady-state+tokamak&amp;rft.au=Menard%2C+J.E.&amp;rft.date=2018&amp;rft.publisher=Princeton+University&amp;' \
      'rft.identifier=http%3A%2F%2Fdoi.org%2Fprinceton%2Ftest123"></span>'
      expect(single_author_dataset.coins).to eq coins
    end
  end

  describe "title" do
    it "does not add extra periods to title and publisher if they come in the source data" do
      citation = described_class.new(["Menard, J.E."], [2018], "Compact steady-state tokamak.", "Data set", "Princeton University.", "http://doi.org/princeton/test123", 1)
      expect(citation.apa).to eq "Menard, J.E. (2018). Compact steady-state tokamak [Data set]. Version 1. Princeton University. http://doi.org/princeton/test123"
    end
  end

  describe "year" do
    it "handles year ranges" do
      citation = described_class.new(["Menard, J.E."], [2018, 2020], "Compact steady-state tokamak.", "Data set", "Princeton University.", "http://doi.org/princeton/test123", 1)
      expect(citation.apa).to eq "Menard, J.E. (2018-2020). Compact steady-state tokamak [Data set]. Version 1. Princeton University. http://doi.org/princeton/test123"
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

  describe "#bibtex_lines" do
    it "breaks lines as expected" do
      citation = described_class.new("", [], "", "", "", "", nil)
      expect(citation.bibtex_lines("hello world", 20)).to eq ["hello world"]
      expect(citation.bibtex_lines("this is a very long text", 20)).to eq ["this is a very long ", "text"]
      expect(citation.bibtex_lines(0)).to eq ["0"]
      expect(citation.bibtex_lines(nil)).to eq [""]
    end
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable Layout/LineLength
