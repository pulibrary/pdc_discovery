# frozen_string_literal: true

describe 'Application landing page', type: :system do
  it "has a footer with latest deploy information" do
    visit '/'
    byebug
    expect(page).to have_content "last updated"
  end
end
