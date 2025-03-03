# frozen_string_literal: true
require 'rails_helper'

describe 'Item page with Globus download integration', type: :system, js: true do
  before do
    load_describe_small_data
  end

  it "displays the Globus download button when the integration is present" do
    visit '/catalog/doi-10-34770-r75s-9j74'
    expect(page).to have_content "Download from Globus"
  end

  it "does not display the Globus download button when the integration is not present" do
    visit '/catalog/doi-10-34770-00yp-2w12'
    expect(page).not_to have_content "Download from Globus"
  end
end
