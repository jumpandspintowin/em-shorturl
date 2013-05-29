require 'em-http-request'
require 'uri'

module EventMachine
    module ShortURL

        ##
        # Driver for bitly.com URL Shortening service. Bitly requires API users
        # to have an account. This can be provided to the driver as either a
        # pre-obtained access token or as a username and password pair
        # (optionally with a client id and secret). If a username and password
        # are provided instead of an access token, login is differed until
        # needed (first call to +shorten+) or can be explicitly called via the
        # +login+ function.

        class Bitly
            include EventMachine::Deferrable
            API_OAUTH_URL = 'https://api-ssl.bitly.com/oauth/access_token'
            API_SHORTEN_URL = 'https://api-ssl.bitly.com/v3/shorten'


            ##
            # Initialize the driver with account details. Despite being
            # required by bitly, the driver does not currently verify that
            # proper account details are given.
            #
            # +account+ takes the following options:
            #   :client_id  The client ID of the registered application
            #   :client_secret  The secret for the client id
            #   :username   A username to use for basic authentication
            #   :password   The password to use for basic authentication
            #   :token  A previously obtained access token to use

            def initialize(account={})
                @client_id = account[:client_id]
                @client_secret = account[:client_secret]
                @username = account[:username]
                @password = account[:password]
                @access_token = account[:token]
                @deferrable_args = [self]
            end


            ##
            # Shortens the given URL. If no access token is known, will call
            # the login function and upon success will call shorten again.

            def shorten(url)
                if @access_token.nil?
                    login { shorten(url) } 
                    return self
                end

                params = get_request_parameters(url)
                request = EM::HttpRequest.new(API_SHORTEN_URL).get(params)
                request.callback(&method(:on_success))
                request.errback(&method(:on_error))
                self
            end


            ##
            # Uses the given username and password to obtain an access token
            # from bitly. If authentication fails, sets the driver's deferrable
            # status to failed.

            def login
                params = {
                    :head => { 'authorization' => [@username, @password] },
                    :body => {}
                }
                params[:body]['client_id'] = @client_id if @client_id
                params[:body]['client_secret'] = @client_secret if @client_secret
                http = EM::HttpRequest.new(API_OAUTH_URL).post(params)

                http.errback do |http|
                    fail(http.error, *@deferrable_args)
                end

                http.callback do |http|
                    if http.response_header.status != 200
                        fail(http.response, *@deferrable_args)
                        next
                    end

                    @access_token = http.response
                    if @access_token.nil?
                        fail('OAuth request did not return an access token', *@deferrable_args)
                        next
                    else
                        yield if block_given?
                    end
                end
            end

            private

            def get_request_parameters(url)
                url = URI(url)
                url.path = '/' if url.path.empty?

                return {
                    :query => {
                        'access_token' => @access_token,
                        'longUrl' => url.to_s,
                        'format' => 'txt'
                    }
                }
            end

            def on_success(http)
                if http.response_header.status != 200
                    fail(http.response, *@deferrable_args)
                    return
                end

                succeed(http.response, *@deferrable_args)
            end

            def on_error(http)
                fail(http.response, *@deferrable_args)
            end
        end
    end
end
