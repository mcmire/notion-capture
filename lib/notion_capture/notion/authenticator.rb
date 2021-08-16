require 'webdrivers'
require 'selenium-webdriver'

module NotionCapture
  module Notion
    class Authenticator
      EMAIL = ENV.fetch('NOTION_EMAIL')
      PASSWORD = ENV.fetch('NOTION_PASSWORD')

      def initialize(token_file)
        @token_file = Pathname.new(token_file)

        token_file.parent.mkpath
      end

      def authenticate
        (token_file.exist? && read_token_file) || reauthenticate
      end

      def reauthenticate
        log_in_to_notion_and_capture_token.tap do |token|
          token_file.write(token)
        end
      end

      private

      attr_reader :token_file

      def read_token_file
        token = token_file.read.strip
        token.empty? ? nil : token
      end

      def log_in_to_notion_and_capture_token
        driver.manage.timeouts.implicit_wait = 3
        driver.navigate.to 'https://www.notion.so/login'
        driver.find_element(:css, "input[type='email']").send_keys(EMAIL)
        driver.find_element(
          :xpath,
          ".//div[@role='button'][contains(text(), 'Continue with email')]",
        ).click
        driver.find_element(:css, "input[type='password']").send_keys(PASSWORD)
        driver.find_element(
          :xpath,
          ".//div[@role='button'][contains(text(), 'Continue with password')]",
        ).click
        driver.find_element(:css, '.notion-sidebar-switcher')
        driver.manage.cookie_named('token_v2').fetch(:value)
      rescue Selenium::WebDriver::Error::NoSuchElementError => error
        screenshot_file =
          Pathname
            .new("../../../tmp/authenticator/login-#{Time.now.to_f}.png")
            .expand_path(__dir__)
        screenshot_file.parent.mkpath
        driver.save_screenshot(screenshot_file)
        raise(
          "#{error.class}: #{error.message}.\n\n" +
            'This is probably the result of a rate limiting issue. A ' +
            "screenshot has been saved to #{screenshot_file} so you can " +
            "verify. Unfortunately there's no way to get around this right " +
            "now — you'll just have to wait.",
        )
      end

      def driver
        @selenium_driver ||=
          begin
            if ENV.include?('GOOGLE_CHROME_SHIM')
              Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_SHIM']
            end
            Webdrivers::Chromedriver.update

            Selenium::WebDriver.for(
              :chrome,
              options: chrome_options,
              desired_capabilities: chrome_desired_capabilities,
            )
          end
      end

      def chrome_options
        Selenium::WebDriver::Chrome::Options.new.tap do |options|
          options.add_argument('--headless')
        end
      end

      def chrome_desired_capabilities
        # ENV['GOOGLE_CHROME_SHIM'] is provided by Heroku's buildpack for Google
        # Chrome
        desired_capabilities_options =
          if ENV.include?('GOOGLE_CHROME_SHIM')
            { 'chromeOptions' => { 'binary' => ENV['GOOGLE_CHROME_SHIM'] } }
          else
            {}
          end

        Selenium::WebDriver::Remote::Capabilities.chrome(
          desired_capabilities_options,
        )
      end
    end
  end
end
