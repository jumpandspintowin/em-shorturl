require 'em-http-request'
require 'uri'

module EventMachine
    module ShortURL

        ##
        # Driver for bitly.com URL Shortening service.

        class Bitly
            include EventMachine::Deferrable
            API_OAUTH_URL = 'https://api-ssl.bitly.com/oauth/access_token'
            API_SHORTEN_URL = 'https://api-ssl.bitly.com/v3/shorten'

            def initialize(account={})
                @client_id = account[:client_id]
                @client_secret = account[:client_secret]
                @username = account[:username]
                @password = account[:password]
                @access_token = account[:token]
                @deferrable_args = [self]
            end

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
