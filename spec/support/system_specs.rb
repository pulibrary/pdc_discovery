# frozen_string_literal: true
Capybara.configure do |config|
  config.default_driver = :chrome

  # Makes sure fields are blanked out before being repopulated when using `fill_in`
  # https://github.com/teamcapybara/capybara/issues/2419#issuecomment-738798878
  config.default_set_options = { clear: :backspace }
end

selenium_url = nil
browser = :chrome
# If we're not in CI then run Selenium from Lando. Makes it much easier to
# upgrade versions of Chrome.
unless ENV["CI"]
  selenium_url = "http://127.0.0.1:4445/wd/hub"
  Capybara.server_host = "0.0.0.0"
  Capybara.always_include_port = true
  Capybara.app_host = "http://host.docker.internal:#{Capybara.server_port}"
  browser = :remote
end

Capybara.register_driver :chrome_headless do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[disable-gpu no-sandbox headless whitelisted-ips window-size=1400,1400])
  options.add_argument(
    "--enable-features=NetworkService,NetworkServiceInProcess"
  )
  options.add_argument("--profile-directory=Default")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: browser, options: options, http_client: client, url: selenium_url)
end

Capybara.register_driver :chrome do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[disable-gpu no-sandbox whitelisted-ips window-size=1400,1400])
  options.add_argument(
    "--enable-features=NetworkService,NetworkServiceInProcess"
  )
  options.add_argument("--headless") unless ENV["RUN_IN_BROWSER"] == "true"
  options.add_argument("--profile-directory=Default")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(app, browser: browser, options: options, http_client: client, url: selenium_url)
end

Capybara.javascript_driver = :chrome_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    driven_by(:chrome)
  end
  config.before(:each, type: :system, js: true, in_browser: true) do
    driven_by(:chrome)
  end
end