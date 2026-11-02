# frozen_string_literal: true

require "capybara/rspec"
require "selenium-webdriver"

Capybara.register_driver :chrome_visible do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--window-size=1280,800")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  # rspec-rails defaults system specs to :selenium_chrome_headless.
  # append_before runs after that default so a real Chrome window opens.
  config.append_before(:each, type: :system) do
    driven_by :chrome_visible
  end
end
