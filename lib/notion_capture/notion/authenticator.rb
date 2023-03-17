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
        ensure_logged_out
        log_in
        capture_token
      rescue Selenium::WebDriver::Error::NoSuchElementError => error
        screenshot_file =
          Pathname
            .new("../../../tmp/authenticator/login-#{Time.now.to_f}.png")
            .expand_path(__dir__)
        screenshot_file.parent.mkpath
        driver.save_screenshot(screenshot_file)
        raise "#{error.class}: #{error.message}.\n\nA screenshot has been saved to #{screenshot_file} so you can take a closer look."
      end

      def ensure_logged_out
        driver.navigate.to 'https://www.notion.so/logout'
        driver.find_element(:xpath, ".//div[contains(text(), 'Log in')]")
        driver.find_element(
          :xpath,
          ".//a[@href='/signup'][contains(text(), 'Get Notion free')]",
        )
      end

      def log_in
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

        begin
          driver.find_element(
            :xpath,
            ".//*[contains(text(), 'Please try again')]",
          )
          raise "Notion has likely detected a high amount of traffic and is preventing us from logging in. We'll try again later."
        rescue Selenium::WebDriver::Error::NoSuchElementError
          # okay, no problem
        end
      end

      def capture_token
        driver.find_element(:css, '.notion-sidebar-switcher')
        driver.manage.cookie_named('token_v2').fetch(:value)
      end

      def driver
        @driver ||=
          begin
            if ENV.include?('GOOGLE_CHROME_SHIM')
              Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_SHIM']
            end
            Webdrivers::Chromedriver.update

            Selenium::WebDriver
              .for(:chrome, options: chrome_options)
              .tap { |driver| driver.manage.timeouts.implicit_wait = 3 }
          end
      end

      def chrome_options
        # ENV['GOOGLE_CHROME_SHIM'] is provided by Heroku's buildpack for Google
        # Chrome
        opts =
          if ENV.include?('GOOGLE_CHROME_SHIM')
            { binary: ENV['GOOGLE_CHROME_SHIM'] }
          else
            {}
          end

        Selenium::WebDriver::Chrome::Options
          .new(**opts)
          .tap do |options|
            options.add_argument('--headless=new')
            options.add_argument('--disable-dev-shm-usage')
          end
      end
    end
  end
end
