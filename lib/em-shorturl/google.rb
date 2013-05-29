require 'em-http-request'
require 'json'

module EventMachine
    module ShortURL

        ##
        # The Google class is the driver for URLShortener to use Google's API
        # for URL shortening.
        #
        # As a deferrable, instances accept callback procs in calls to
        # callback() and errback(). Callbacks are provided arguments
        # +shorturl+ and +self+, while errbacks are provided +err_string+
        # and +self+.

        class Google
            include EventMachine::Deferrable

            # Specifies the API URL for shortening URLs
            API_URL = "https://www.googleapis.com/urlshortener/v1/url"


            ##
            # Initializes the driver instance, optionally with account information
            # for making requests on behalf of an account. Benefits of using an api key
            # include higher request limits and stat tracking.
            #
            # The +account+ argument may take the following options:
            #   :apikey     Defines an apikey to use for the request

            def initialize(account={})
                @deferrable_args = [self]
                @account_apikey = account[:apikey]
            end


            ##
            # Performs the request of shortening a URL asynchronously. Returns self,
            # which is a deferrable. This allows a usage like the following:
            #
            #   EM::ShortURL::Google.new.shorten('http://google.com').callback do |u,d|
            #       puts "Shorturl: #{u}"
            #   end

            def shorten(url)
                params = get_request_parameters(url)
                request = EventMachine::HttpRequest.new(API_URL).post(params)
                request.callback(&method(:on_success))
                request.errback(&method(:on_error))
                self
            end


            private


            ##
            # Creates the parameter hash for the HTTP Request to Google

            def get_request_parameters(url)
                options = {
                    :head => { "Content-Type" => "application/json" },
                    :body => { "longUrl" => url }.to_json
                }

                if @account_apikey
                    options[:query] = { "key" => @account_apikey }
                end

                options
            end


            ##
            # Callback for HttpRequest object upon success. Parses the response
            # as JSON, checks for a Google API error, and finally saves the
            # short URL as an instance variable. If any of the above fail,
            # sets the error message and sets the deferrable status to failure.

            def on_success(http)
                response = nil

                # Handle HTTP Status other than 200
                if http.response_header.status != 200
                    error = http.response_header.http_reason
                    fail(error, *@deferrable_args)
                    return
                end


                # Handle JSON Failure
                begin
                    response = JSON.parse(http.response)
                rescue JSON::ParseError => e
                    error = e.message
                    fail(error, *@deferrable_args)
                    return
                end

                # Handle google API Error
                if response['error']
                    error = response['error']['message']
                    fail(error, *@deferrable_args)
                    return
                end

                # Odd case if response['id'] doesn't exist (Should't happen)
                if response['id'].nil?
                    error = "No short URL was returned (Google API Change?)"
                    fail(error, *@deferrable_args)
                end

                # Return the short URL
                short_url = response['id']
                succeed(short_url, *@deferrable_args)
            end


            ##
            # Callback for an error from HttpRequest (caused by a server
            # outage of lack of connectivity). Simply forwards the error
            # value and sets the deferrable status to fail.

            def on_error(http)
                error = http.error
                fail(error, *@deferrable_args)
            end
        end
    end
end

