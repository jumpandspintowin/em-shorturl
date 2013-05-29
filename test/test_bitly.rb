require "test/unit"
require "em-shorturl/bitly"

class TestBitly < Test::Unit::TestCase
    TEST_URL = 'http://google.com'
    SHORT_REGEX = /^http:\/\/bit.ly\/\S+$/
    USER_ENV_VAR = 'bitly_user'
    PASS_ENV_VAR = 'bitly_pass'
    TOKEN_ENV_VAR = 'bitly_token'

    def test_no_auth
        EM.run do
            bitly = EM::ShortURL::Bitly.new
            bitly.errback { |e| assert(true, e); EM.stop }
            bitly.callback { |s| assert(false, s); EM.stop }
            bitly.shorten(TEST_URL)
        end
    end

    if ENV[USER_ENV_VAR] and ENV[PASS_ENV_VAR]
        def test_with_oauth_basic
            EM.run do
                bitly = EM::ShortURL::Bitly.new(:username => ENV[USER_ENV_VAR], :password => ENV[PASS_ENV_VAR])
                set_asserts(bitly)
                bitly.shorten(TEST_URL)
            end
        end
    else
        warn "Skipping test_with_oauth_basic: '#{USER_ENV_VAR}' and '#{PASS_ENV_VAR}' environment variable must be set"
    end

    if ENV[TOKEN_ENV_VAR]
        def test_with_oauth_token
            EM.run do
                bitly = EM::ShortURL::Bitly.new(:token => ENV[TOKEN_ENV_VAR])
                set_asserts(bitly)
                bitly.shorten(TEST_URL)
            end
        end
    else
        warn "Skipping test_with_oauth_token: '#{TOKEN_ENV_VAR}' environment variable must be set"
    end

    private
    def set_asserts(deferrable)
        deferrable.callback { |s| assert_match(SHORT_REGEX, s); EM.stop }
        deferrable.errback { |e| assert(false, e); EM.stop}
    end
end
