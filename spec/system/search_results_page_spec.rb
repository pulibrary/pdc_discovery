# frozen_string_literal: true

describe 'Search Results Page', type: :system, js: true do
  before do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
    data = file_fixture('single_item.xml').read
    indexer = Indexer.new(data)
    indexer.index
  end

  it "renders expected fields" do
    visit '/?search_field=all_fields&q='

    expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    expect(page).to have_content 'Stotler, D., F. Scotti, R.E. Bell, A. Diallo' # authors
    expect(page).to have_content 'Atomic and molecular density data in the outer midplane of NSTX' # abstract
  end
end
