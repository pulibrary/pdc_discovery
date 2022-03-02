# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.production? || Rails.env.staging?
  map '/discovery/' do
    run Rails.application
  end
else
  run Rails.application
end

Rails.application.load_server
