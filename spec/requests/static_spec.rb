# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Static Pages", type: :request do
  it "has an about page" do
    get "/about"
    expect(response).to have_http_status(:success)
  end
end
