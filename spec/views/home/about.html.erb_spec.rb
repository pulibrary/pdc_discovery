# frozen_string_literal: true
describe '/about', type: :system do
  it 'renders the about page' do
    visit '/about'
    expect(page).to have_text("About Princeton's Research Data Repository")
  end
end
