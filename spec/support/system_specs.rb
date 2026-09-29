# frozen_string_literal: true
Capybara.configure do |config|
  # config.default_driver = :chrome

  # Makes sure fields are blanked out before being repopulated when using `fill_in`
  # https://github.com/teamcapybara/capybara/issues/2419#issuecomment-738798878
  config.default_set_options = { clear: :backspace }
end

# If we're not in CI then run Selenium from Lando. Makes it much easier to
# upgrade versions of Chrome.
if ENV["RUN_IN_BROWSER"]
  selenium_url = "http://127.0.0.1:4445/wd/hub"
  Capybara.server_host = "0.0.0.0"
  Capybara.always_include_port = true
  Capybara.app_host = "http://host.docker.internal:#{Capybara.server_port}"
end

Capybara.register_driver :chrome do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[disable-gpu no-sandbox whitelisted-ips window-size=1400,1400])
  options.add_argument(
    "--enable-features=NetworkService,NetworkServiceInProcess"
  )
  options.add_argument("--profile-directory=Default")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: :remote, options: options, http_client: client, url: selenium_url)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["RUN_IN_BROWSER"]
      driven_by(:chrome)
    else
      driven_by(:rack_test)
    end
  end

  config.before(:each, type: :system, js: true) do
    if ENV["RUN_IN_BROWSER"]
      driven_by(:chrome)
    else
      driven_by(:selenium_headless)
    end
  end
end