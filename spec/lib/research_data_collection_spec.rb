# frozen_string_literal: true

RSpec.describe ResearchDataCollection do
  let(:csv_data) do
    {
      "ParentCommunity" => "Princeton Plasma Physics Laboratory",
      "Community" => "Advanced Projects",
      "CollectionName" => "Socio Economic",
      "Handle" => "88435/dsp01sf268746p",
      "CollectionID" => "1305",
      "ItemCount" => "5",
      nil => nil
    }
  end
  let(:csv_row) { CSV::Row.new(csv_data.keys, csv_data.values) }
  let(:rdc) { described_class.new(csv_row) }

  it "takes a CSV::Row as an argument" do
    expect(rdc.parent_community).to eq "Princeton Plasma Physics Laboratory"
    expect(rdc.community).to eq "Advanced Projects"
    expect(rdc.collection_name).to eq "Socio Economic"
    expect(rdc.handle).to eq "88435/dsp01sf268746p"
    expect(rdc.collection_id).to eq "1305"
    expect(rdc.item_count).to eq 5
  end
end
