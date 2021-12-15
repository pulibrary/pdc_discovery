# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe SolrDocument do
  describe "#authors_et_al" do
    it "handles multiple authors" do
      doc = described_class.new({ id: "1", author_tesim: [] })
      expect(doc.authors_et_al).to eq ""

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck"] })
      expect(doc.authors_et_al).to eq "Eve Tuck"

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck", "K. Wayne Yang"] })
      expect(doc.authors_et_al).to eq "Eve Tuck & K. Wayne Yang"

      doc = described_class.new({ id: "1", author_tesim: ["Eve Tuck", "K. Wayne Yang", "Jane Smith"] })
      expect(doc.authors_et_al).to eq "Eve Tuck et al."
    end
  end

  describe "#icons_css" do
    it "handles icons for known genres" do
      doc = described_class.new({ id: "1", genre_ssim: ["Dataset"] })
      expect(doc.icon_css).to eq "bi-stack"

      doc = described_class.new({ id: "1", genre_ssim: ["moving image"] })
      expect(doc.icon_css).to eq "bi-film"
    end

    it "handles icon for an unknown genre" do
      doc = described_class.new({ id: "1", genre_ssim: ["unknown genre"] })
      expect(doc.icon_css).to eq "bi-file-earmark-fill"
    end
  end
end
# rubocop:enable RSpec/ExampleLength
