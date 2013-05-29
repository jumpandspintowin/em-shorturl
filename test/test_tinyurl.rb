require "test/unit"
require "em-shorturl/tinyurl"

class TestTinyURL < Test::Unit::TestCase
    TEST_URL = 'http://google.com'
    SHORT_REGEX = /^http:\/\/tinyurl\.com\/\S+$/

    def test_tinyurl
        EM.run do
            tinyurl = EM::ShortURL::TinyURL.new
            set_asserts(tinyurl)
            tinyurl.shorten(TEST_URL)
        end
    end

    private
    def set_asserts(deferrable)
        deferrable.callback { |s| assert_match(SHORT_REGEX, s); EM.stop }
        deferrable.errback { |e| assert(false, e); EM.stop}
    end
end
