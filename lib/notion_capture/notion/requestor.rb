require 'http'
require 'logger'

module NotionCapture
  module Notion
    class Requestor
      BASE_URL = 'https://www.notion.so/api/v3'

      def self.debug!
        self.logger = Logger.new(STDOUT)
      end

      def self.call(verb:, path:, options: {}, authenticator:)
        new(
          verb: verb,
          path: path,
          options: options,
          authenticator: authenticator,
        ).call
      end

      singleton_class.attr_accessor :logger
      self.logger = Logger.new('/dev/null')

      private_class_method :new

      def initialize(verb:, path:, options:, authenticator:)
        @verb = verb
        @path = path
        @options = options
        @authenticator = authenticator

        @http =
          HTTP
            .use(logging: { logger: self.class.logger })
            .headers('Accept' => 'application/json')
        @auth_token = authenticator.authenticate
      end

      def call
        make_request!
      rescue FailedResponseError => error
        if error.invalid_token?
          @auth_token = authenticator.reauthenticate
          retry
        else
          raise error
        end
      end

      private

      attr_reader :verb, :path, :options, :authenticator, :http, :auth_token

      def make_request!
        response = make_request

        if response.status.success?
          response.parse
        else
          raise FailedResponseError.create(response)
        end
      end

      def make_request
        http
          .headers('Cookie' => "token_v2=#{auth_token}")
          .public_send(verb, BASE_URL + path, **options)
      end

      class FailedResponseError < StandardError
        attr_accessor :response

        def self.create(response)
          allocate.tap do |error|
            error.response = response
            error.__send__(:initialize)
          end
        end

        def initialize(message = nil)
          super(
            message ||
              "Request failed with #{response.status.code}: #{response.body.to_s}",
          )
        end

        def invalid_token?
          response.parse.fetch('name') == 'UnauthorizedError'
        end
      end
    end
  end
end
