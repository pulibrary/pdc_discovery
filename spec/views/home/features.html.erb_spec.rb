# frozen_string_literal: true
describe '/features', type: :system do
  it 'renders the features page' do
    visit '/features'
    expect(page).to have_text("Repository features")
    expect(page).to have_text("Data Curation")
    expect(page).to have_text("Access Options")
    expect(page).to have_text("Persistent Identifiers")
    expect(page).to have_text("Discovery and access")
    expect(page).to have_text("Metadata Schema")
    expect(page).to have_text("ORCID ID Support")
    expect(page).to have_text("Preservation and long-term storage")
    expect(page).to have_text("Large Data")
    expect(page).to have_text("Meets NSTC Desirable Characteristics")
    expect(page).to have_text("Organizational infrastructure")
    expect(page).to have_text("Digital Object Management")
    expect(page).to have_text("Technology")
  end
end
