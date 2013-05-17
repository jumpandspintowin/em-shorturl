require 'em-http-request'
require 'json'

module EventMachine
    module URLShortener
        class Google
            include EventMachine::Deferrable

            API_URL = "https://www.googleapis.com/urlshortener"
            SHORTEN_ACTION = "/v1/url"

            attr_reader :long_url
            attr_reader :short_url

            def initialize(url, success_callback = nil, error_callback = nil)
                @long_url = url
                @short_url = nil
                @error = nil
                @deferrable_args = [self]

                callback(&success_callback) if success_callback
                errback(&error_callback) if error_callback
            end

            def shorten
                puts "URL: #{API_URL + SHORTEN_ACTION}"
                request = EventMachine::HttpRequest.new(API_URL + SHORTEN_ACTION).post(
                    :head => { "Content-Type" => "application/json" },
                    :body => { "longUrl" => @long_url }.to_json
                )
                request.callback(&method(:on_success))
                request.errback(&method(:on_error))
                self
            end

            private
            def on_success(http)
                response = nil

                begin
                    response = JSON.parse(http.response)
                rescue
                end

                @short_url = response['id']
                succeed(*@deferrable_args)
            end

            def on_error(http)
                @error = http.error
                @deferrable_args << @error
                fail(*@deferrable_args)
            end
        end
    end
end

