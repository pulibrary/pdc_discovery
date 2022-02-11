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

  describe "title searches" do
    it "finds record by title" do
      # Notice that the search is successful even with a slight variation in terms (profile vs profiles)
      visit '/?search_field=title&q=profile'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    end
    it "does not find non-existing titles" do
      visit '/?search_field=title&q=crofile'
      expect(page).to have_content('No results found')
    end
  end

  describe "subject searches" do
    it "finds record by subject" do
      # Notice that the search is successful even with a slight variation in terms ("monte carlo" vs "Monte-Carlo simulation")
      visit '/?search_field=subject&q=monte+carlo'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
      expect(page.html.include?('/?f%5Bsubject_all_ssim%5D%5B%5D=Monte-Carlo+simulation&amp;q=monte+carlo&amp;search_field=subject')).to be true
    end
  end

  describe "author searches" do
    it "finds record by subject" do
      visit '/?search_field=author&q=podesta'
      expect(page).to have_link('Midplane neutral density profiles in the National Spherical Torus Experiment', href: '/catalog/78348')
    end
  end
end
