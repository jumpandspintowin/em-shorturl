require "test/unit"
require "em-shorturl/google"

class TestGoogle < Test::Unit::TestCase
    TEST_URL = 'http://google.com'
    API_ENV_VAR = 'google_apikey'

    def test_no_auth
        EM.run do
            google = EM::ShortURL::Google.new
            set_asserts(google)
            google.shorten(TEST_URL)
        end
    end

    if ENV[API_ENV_VAR]
        def test_with_apikey

            EM.run do

                google = EM::ShortURL::Google.new(:apikey => ENV[API_ENV_VAR])
                set_asserts(google)
                google.shorten(TEST_URL)
            end
        end
    else
        warn "Skipping test_with_apikey: No '#{API_ENV_VAR}' environment variable set"
    end

    private
    def set_asserts(deferrable)
        deferrable.callback { |s| assert_match(/^http:\/\/goo.gl\/\S+$/, s); EM.stop }
        deferrable.errback { |e| assert(false, e); EM.stop}
    end
end
