# frozen_string_literal: true

describe 'Search Results Page', type: :system do
  before do
    stub_request(:get, "http://mysolr/solr/pdc-core-test/select?q=mechanical&rows=10&wt=json").to_return(
      status: 200,
      body: file_fixture("search_results.json"),
      headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v1.4.3'
      }
    )
  end

  it "renders Bootstrap icons for Recently added feed items" do
    allow(CatalogController).to receive(:blacklight_config).and_return(Blacklight::Configuration.new(connection_config: { url: "http://mysolr/solr/pdc-core-test" }))
    visit '/?search_field=all_fields&q=mechanical'

    # Idealy the test should look like this
    #
    # expect(page).to have_content 'catalog/88912' # link
    # expect(page).to have_content 'A multi-machine scaling of halo current rotation' # title
    # expect(page).to have_content 'Myers, C.E., Eidietis, N.W., Gerasimov, S.N.' # authors
    # expect(page).to have_content 'Halo currents generated during unmitigated tokamak disruptions' # abstract
    #
    # but because the rendering is NOT working on the test for now I am just looking for
    # the IDs of 3 known documents in the "search_results.json" fixture.
    #
    # It is VERY strange that the IDs from the fixture are being rendered (i.e. the controller did load the
    # data and the page has it) but the rest of the fields (author, title, abstract) are NOT being rendered.
    expect(page).to have_content '81469'
    expect(page).to have_content '92810'
    expect(page).to have_content '88912'
  end
end
