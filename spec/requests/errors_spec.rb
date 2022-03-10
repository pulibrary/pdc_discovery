# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "GET /not_found" do
    it "returns http success" do
      get "/errors/not_found"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /internal_server_error" do
    it "returns http success" do
      get "/errors/internal_server_error"
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end