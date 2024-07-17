# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateNormalizer do
  let(:years) { ['2015'] }
  let(:months_and_years) { ['2015-08'] }
  let(:timestamps) { ['2015-08-18T18:14:22Z'] }
  let(:month_year_name) { ['August 2020'] }

  describe "#format_array_for_display" do
    it "formats four digit years" do
      formatted_dates = described_class.format_array_for_display(years)
      expect(formatted_dates.first).to eq "2015"
    end

    it "formats months and years" do
      formatted_dates = described_class.format_array_for_display(months_and_years)
      expect(formatted_dates.first).to eq "August 2015"
    end

    it "formats ISO-8601 timestamps" do
      formatted_dates = described_class.format_array_for_display(timestamps)
      expect(formatted_dates.first).to eq "18 August 2015"
    end
  end

  describe "#years_from_dates" do
    it "gets years correctly" do
      expect(described_class.years_from_dates(timestamps)).to eq [2015]
      expect(described_class.years_from_dates(months_and_years)).to eq [2015]
      expect(described_class.years_from_dates(years)).to eq [2015]
      expect(described_class.years_from_dates(month_year_name)).to eq [2020]
    end

    it "handles bad dates" do
      expect(described_class.years_from_dates(["2015-99-18T18:14:22Z"])).to eq []
    end
  end

  describe "#strict_dates" do
    it "sorts dates ascending" do
      expect(described_class.strict_dates(["2021-12-14", nil, "1999-12-31"])).to eq ["1999-12-31", "2021-12-14"]
    end
  end

  describe "#strict_date" do
    it "handles full dates correctly" do
      expect(described_class.strict_date("2021-12-14")).to eq "2021-12-14"
      expect(described_class.strict_date("2021-12-14T18:14:22Z")).to eq "2021-12-14"
      expect(described_class.strict_date("2021-2-8")).to eq "2021-02-08"
    end

    it "handles partial dates correctly" do
      expect(described_class.strict_date("2021-12")).to eq "2021-12-01"
      expect(described_class.strict_date("2021")).to eq "2021-01-01"
    end

    it "detects bad dates" do
      expect(described_class.strict_date("2021-14-14")).to eq nil
      expect(described_class.strict_date("202")).to eq nil
      expect(described_class.strict_date("blah")).to eq nil
      expect(described_class.strict_date("")).to eq nil
      expect(described_class.strict_date(nil)).to eq nil
    end
  end
end
