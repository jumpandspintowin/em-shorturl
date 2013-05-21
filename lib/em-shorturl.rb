require 'eventmachine'
require 'em-shorturl/version'
require 'em-shorturl/google'

module EventMachine
    module ShortURL
        DEFAULT_DRIVER = :google
        DRIVERS = {
            :google => ShortURL::Google
        }

        def self.shorten(url, driver=DEFAULT_DRIVER, account={})
            raise KeyError, "Driver does not exist" unless DRIVERS[driver]

            r = DRIVERS[driver].new(account)
            r.shorten(url)
        end
    end
end
