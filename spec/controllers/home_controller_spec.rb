# frozen_string_literal: true
require "rails_helper"

RSpec.describe HomeController do
  it "Detects bots trying to use the Contact Us form" do
    # We return HTTP 200 to bots but we do nothing
    get :contact_us, params: { feedback: "beep beep", name: "jane", email: "jane@another.edu", comment: "hello" }
    expect(response).to be_successful
  end

  it "Notifies reals users that we have received the request" do
    get :contact_us, params: { name: "jane", email: "jane@another.edu", comment: "hello" }
    expect(flash.alert).to eq "We have sent your message to our team."
    expect(response).to be_redirect
  end
end
