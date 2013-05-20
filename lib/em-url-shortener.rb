require 'eventmachine'
require 'em-url-shortener/version'
require 'em-url-shortener/google'

module EventMachine
    module URLShortener
        DEFAULT_DRIVER = :google
        DRIVERS = {
            :google => URLShortener::Google
        }

        def self.shorten(url, driver=DEFAULT_DRIVER, account={})
            raise KeyError, "Driver does not exist" unless DRIVERS[driver]

            r = DRIVERS[driver].new(account)
            r.shorten(url)
        end
    end
end
