# frozen_string_literal: true

describe 'Single item page', type: :system, js: true do
  let(:community_fetch_with_expanded_metadata) { file_fixture("single_item.xml").read }
  let(:indexer) do
    DspaceIndexer.new(community_fetch_with_expanded_metadata)
  end

  before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
    indexer.index
  end

  it "has expected header fields" do
    visit '/catalog/78348'
    expect(page).to have_css '.document-title-heading'
    expect(page).to have_css '.authors-heading'
    expect(page).to have_css 'div.authors-heading > span.author-name'
    expect(page).to have_css '.issue-date-heading'
  end

  # rubocop:disable RSpec/ExampleLength
  it "has expected metadata" do
    visit '/catalog/78348'
    expect(page).to have_content "Midplane neutral density profiles in the National Spherical Torus Experiment"
    find('#show-more-metadata-link').click
    author1 = '<span class="author-name">Stotler, D.;</span>'
    author2 = '<span class="author-name">F. Scotti;</span>'
    community1 = '<a href="/?f[communities_ssim][]=Spherical+Torus&amp;q=&amp;search_field=all_fields">Spherical Torus</a>'
    community2 = '<a href="/?f[communities_ssim][]=Princeton+Plasma+Physics+Laboratory&amp;q=&amp;search_field=all_fields">Princeton Plasma Physics Laboratory</a>'
    collection = '<span><a href="/?f[collection_tag_ssim][]=NSTX&amp;q=&amp;search_field=all_fields">NSTX</a></span>'
    expected_values = [author1, author2, community1, community2, collection]
    expected_values.each do |value|
      expect(page.html.include?(value)).to be true
    end
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable Layout/LineLength
  it "has expected citation information" do
    visit '/catalog/78348'
    apa_citation = "Stotler, D., F. Scotti, R.E. Bell, A. Diallo, B.P. LeBlanc, M. Podesta, A.L. Roquemore, & P.W. Ross. (2016). Midplane neutral density profiles in the National Spherical Torus Experiment [Data set]. Princeton Plasma Physics Laboratory, Princeton University."
    expect(page).to have_content apa_citation
    expect(page.html.include?('<button id="show-apa-citation-button"')).to be true
    expect(page.html.include?('<button id="show-bibtex-citation-button"')).to be true
  end
  # rubocop:enable Layout/LineLength

  it "has expected HTML SPAN element with COinS information" do
    visit '/catalog/78348'
    expect(page.html.include?('<span class="Z3988"')).to be true
  end

  it "renders pageviews and downloads stats" do
    visit '/catalog/78348'
    expect(page.html.include?('<span id="pageviews"')).to be true
    expect(page.html.include?('<span id="downloads"')).to be true
  end

  context "clickable links" do
    let(:globus_download_link) { "https://app.globus.org/file-manager?origin_id=dc43f461-0ca7-4203-848c-33a9fc00a464=%2Fvsj7-4j83%2F" }

    it "renders hyperlinks in the abstract and description fields" do
      visit '/catalog/78348'
      expect(page.html.include?('<a href="http://torus.example.com">http://torus.example.com</a>')).to be true
      links = page.find("div.document-description").find_all("a").map { |a| a["href"] }
      expect(links.include?(globus_download_link)).to be true
    end
  end
end
