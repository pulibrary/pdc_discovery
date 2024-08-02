# frozen_string_literal: true
describe '/contributors', type: :system do
  it 'renders the contributors page' do
    visit '/contributors'
    expect(page).to have_text("The Repository Team")
    expect(page).to have_text("Curation Service, Princeton Research Data Service (PRDS)")
    expect(page).to have_text("Repository Management, Princeton Research Data Service (PRDS)")
    expect(page).to have_text("Other Contributors")
    expect(page).to have_text("Project Administration")
    expect(page).to have_text("Infrastructure Development")
    expect(page).to have_text("Research Data and Scholarship Services (RDSS)")
    expect(page).to have_text("Library IT Operations")
    expect(page).to have_text("Emeritus Contributors")
  end
end
