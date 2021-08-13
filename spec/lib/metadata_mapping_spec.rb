# frozen_string_literal: true

RSpec.describe Indexer do
  describe 'indexing a single record' do
    let(:single_item) { File.read(File.join(fixture_path, 'single_item.xml')) }
    let(:indexer) do
      described_class.new(single_item)
    end
    let(:indexed_record) do
      Blacklight.default_index.connection.delete_by_query("*:*")
      Blacklight.default_index.connection.commit
      indexer.index
      response = Blacklight.default_index.connection.get 'select', params: { q: '*:*' }
      response["response"]["docs"].first
    end

    it "abstract" do
      expect(indexed_record["abstract_tsim"].first).to match(/discharge parameters/)
    end

    it "author" do
      authors = ['Stotler, D.', 'F. Scotti', 'R.E. Bell', 'A. Diallo', 'B.P. LeBlanc', 'M. Podesta', 'A.L. Roquemore', 'P.W. Ross']
      expect(indexed_record["author_tsim"]).to eq authors
    end

    it "contributor" do
      expect(indexed_record["contributor_tsim"]).to contain_exactly "Stotler, Daren"
    end

    it "description" do
      expect(indexed_record["description_tsim"]).to contain_exactly "This is a fake description."
    end

    it "title" do
      expect(indexed_record["title_ssm"]).to contain_exactly "Midplane neutral density profiles in the National Spherical Torus Experiment"
      expect(indexed_record["title_tsim"]).to contain_exactly "Midplane neutral density profiles in the National Spherical Torus Experiment"
    end

    it "uri" do
      expect(indexed_record["uri_tsim"]).to contain_exactly "http://arks.princeton.edu/ark:/88435/dsp01zg64tp300"
    end
  end
end
