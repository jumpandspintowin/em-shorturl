require 'eventmachine'
require "test/unit"
require_relative "../lib/em-url-shortener/google.rb"
require_relative "../lib/em-url-shortener.rb"

class TestGoogle < Test::Unit::TestCase
    TEST_URL = 'http://google.com'
    API_ENV_VAR = 'google_apikey'

    def test_no_auth
        EM.run do
            google = EM::URLShortener::Google.new
            set_asserts(google)
            google.shorten(TEST_URL)
        end
    end

    def test_with_apikey
        EM.run do
            assert(false, "No '#{API_ENV_VAR}' environment variable set") unless ENV[API_ENV_VAR]

            google = EM::URLShortener::Google.new(:apikey => ENV[API_ENV_VAR])
            set_asserts(google)
            google.shorten(TEST_URL)
        end
    end

    def test_module_call_no_auth
        EM.run do
            google = EM::URLShortener.shorten(TEST_URL, :google)
            set_asserts(google)
        end
    end

    private
    def set_asserts(deferrable)
        deferrable.callback { |s| assert_match(/^http:\/\/goo.gl\/\S+$/, s); EM.stop }
        deferrable.errback { |e| assert(false, e); EM.stop}
    end
end
