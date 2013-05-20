require 'em-http-request'
require 'json'

module EventMachine
    module URLShortener

        ##
        # The Google class is the driver for URLShortener to use Google's API
        # for URL shortening.

        class Google
            include EventMachine::Deferrable

            # Specifies the API base URL
            API_URL = "https://www.googleapis.com/urlshortener"

            # Specifies the API relative path to url shortening
            SHORTEN_ACTION = "/v1/url"

            attr_reader :long_url
            attr_reader :short_url
            attr_reader :error


            ##
            # Takes the URL to shorten and optionally two callbacks for success
            # and error. Does not immediately shorten the URL.

            def initialize(url, success_callback = nil, error_callback = nil)
                @long_url = url
                @short_url = nil
                @error = nil
                @deferrable_args = [self]

                callback(&success_callback) if success_callback
                errback(&error_callback) if error_callback
            end

            
            ##
            # Performs the request of shortening a URL asynchronously.

            def shorten
                request = EventMachine::HttpRequest.new(API_URL + SHORTEN_ACTION).post(
                    :head => { "Content-Type" => "application/json" },
                    :body => { "longUrl" => @long_url }.to_json
                )
                request.callback(&method(:on_success))
                request.errback(&method(:on_error))
                self
            end


            private
            
            ##
            # Callback for HttpRequest object upon success. Parses the response
            # as JSON, checks for a Google API error, and finally saves the
            # short URL as an instance variable. If any of the above fail,
            # sets the error message and sets the deferrable status to failure.

            def on_success(http)
                response = nil

                # Handle JSON Failure
                begin
                    response = JSON.parse(http.response)
                rescue JSON::ParseError => e
                    @error = e.message
                    @deferrable_args << @error
                    fail(*@deferrable_args)
                    return
                end

                # Handle google API Error
                if response['error']
                    @error = response['error']['message']
                    @deferrable_args << @error
                    fail(*@deferrable_args)
                    return
                end

                # Return the short URL
                @short_url = response['id']
                succeed(*@deferrable_args)
            end


            ##
            # Callback for an error from HttpRequest (caused by a server
            # outage of lack of connectivity). Simply forwards the error
            # value and sets the deferrable status to fail.

            def on_error(http)
                @error = http.error
                @deferrable_args << @error
                fail(*@deferrable_args)
            end
        end
    end
end

