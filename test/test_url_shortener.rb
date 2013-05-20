require 'eventmachine'
require "test/unit"
require "em-url-shortener"

class TestURLShortener < Test::Unit::TestCase
    def test_bad_driver_should_raise_KeyError
        assert_raise(KeyError) do
            EM.run do
                r = EM::URLShortener.shorten('http://google.com', :nonexistent_driver)
                EM.stop
            end
        end
    end
end
