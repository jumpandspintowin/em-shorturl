require 'eventmachine'
require 'em-url-shortener/google'

module EventMachine
    module URLShortener
        DEFAULT_DRIVER = :google
        DRIVERS = {
            :google => URLShortener::Google
        }

        def self.shorten(url, driver=DEFAULT_DRIVER, *args)
            r = DRIVERS[driver].new(url, *args)
            r.shorten
        end
    end
end
