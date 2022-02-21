# frozen_string_literal: true

describe 'Single item page', type: :system, js: true do
  let(:community_fetch_with_expanded_metadata) { file_fixture("single_item.xml").read }
  let(:indexer) do
    Indexer.new(community_fetch_with_expanded_metadata)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
  end

  it "has expected metadata" do
    visit '/catalog/78348'
    expect(page).to have_content "Midplane neutral density profiles in the National Spherical Torus Experiment"

    authors = "<span>Stotler, D.; F. Scotti; R.E. Bell; A. Diallo; B.P. LeBlanc; M. Podesta; A.L. Roquemore; P.W. Ross</span>"
    expect(page.html.include?(authors)).to be true
  end

  # rubocop:disable Layout/LineLength
  it "has expected citation information" do
    visit '/catalog/78348'
    apa_citation = "Stotler, D., F. Scotti, R.E. Bell, A. Diallo, B.P. LeBlanc, M. Podesta, A.L. Roquemore, & P.W. Ross. (2016). Midplane neutral density profiles in the National Spherical Torus Experiment [Data set]. Princeton Plasma Physics Laboratory, Princeton University."
    expect(page).to have_css 'tr.citation-row'
    expect(page).to have_content apa_citation
  end
  # rubocop:enable Layout/LineLength

  it "has expected HTML SPAN element with COinS information" do
    visit '/catalog/78348'
    expect(page.html.include?('<span class="Z3988"')).to be true
  end
end
