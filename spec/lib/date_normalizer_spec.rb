# frozen_string_literal: true

RSpec.describe DateNormalizer do
  let(:years) { ['2015'] }
  let(:months_and_years) { ['2015-08'] }
  let(:timestamps) { ['2015-08-18T18:14:22Z'] }

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
end
