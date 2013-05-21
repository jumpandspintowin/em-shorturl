require 'eventmachine'
require "test/unit"
require "em-shorturl"

class TestURLShortener < Test::Unit::TestCase
    def test_bad_driver_should_raise_KeyError
        assert_raise(KeyError) do
            EM.run do
                r = EM::ShortURL.shorten('http://google.com', :nonexistent_driver)
                EM.stop
            end
        end
    end
end
