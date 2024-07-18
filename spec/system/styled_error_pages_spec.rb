# frozen_string_literal: true
require 'rails_helper'

describe 'Styled error page', type: :system, js: true do
  around do |example|
    Rails.application.config.consider_all_requests_local = false
    example.run
    Rails.application.config.consider_all_requests_local = true
  end

  it "renders for Blacklight RecordNotFound exceptions" do
    visit '/catalog/fake_item'
    expect(page).not_to have_content "Blacklight::Exceptions::RecordNotFound"
    expect(page).to have_content "We're unable to find the page you're looking for"
  end

  it "renders for generalized 404 errors" do
    visit '/obviously_fake_url'
    expect(page).to have_content "We're unable to find the page you're looking for"
  end
end
