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

  describe "GET /not_found.json" do
    it "returns a 404 response code with an empty body" do
      get "/errors/not_found.json"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_empty
    end
  end

  describe "GET /not_found.rss" do
    it "returns a 404 response code with an empty body" do
      get "/errors/not_found.rss"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_empty
    end
  end

  describe "GET /not_found.xml" do
    it "returns a 404 response code with an empty body" do
      get "/errors/not_found.xml"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_empty
    end
  end

  describe "GET /not_found.svg" do
    it "returns a 404 response code with an html page" do
      get "/errors/not_found.svg"
      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to be_empty
    end
  end
end
