require 'eventmachine'
require "test/unit"
require_relative "../lib/em-url-shortener/google.rb"
require_relative "../lib/em-url-shortener.rb"

class TestGoogle < Test::Unit::TestCase
    TEST_URL = 'http://google.com'

    def test_no_auth
        EM.run do
            google = EM::URLShortener::Google.new(TEST_URL)
            google.callback { |s| assert_match(/^http:\/\/goo.gl\/\S+$/, s.short_url); EM.stop }
            google.errback { |s,e| assert(false); EM.stop}
            google.shorten
        end
    end

    def test_module_call
        EM.run do
            google = EM::URLShortener.shorten(TEST_URL, :google)
            google.callback { |s| assert_match(/^http:\/\/goo.gl\/\S+$/, s.short_url); EM.stop }
            google.errback { |s,e| assert(false); EM.stop}
            google.shorten
        end
    end
end
