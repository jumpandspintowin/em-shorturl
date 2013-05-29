require 'eventmachine'
require 'em-shorturl/version'
require 'em-shorturl/google'
require 'em-shorturl/tinyurl'

module EventMachine

    ##
    # The ShortURL module for EventMachine adds an asynchronous interface to
    # shortening urls using several publically available URL shortening
    # services. Several drivers may be provided, and the top level module
    # provides a uniform and easy interface to using any of these services.

    module ShortURL
        DEFAULT_DRIVER = :google
        DRIVERS = {
            :google => ShortURL::Google,
            :tinyurl => ShortURL::TinyURL
        }


        ##
        # Takes a URL and returns the driver instance, which should then have
        # its callback and errback attributes set. Optionally accepts +driver+
        # and +account+. +driver+ is a symbol which maps to a driver class and
        # +account+ is a driver-specific hash of account information.
        #
        # Raises +KeyError+ if the driver is not mapped.

        def self.shorten(url, driver=DEFAULT_DRIVER, account={})
            raise KeyError, "Driver does not exist" unless DRIVERS[driver]

            r = DRIVERS[driver].new(account)
            r.shorten(url)
        end
    end
end
