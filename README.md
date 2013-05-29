EventMachine ShortURL Gem
=========================

The `em-shorturl` gem is a module extending EventMachine to provide asynchronous URL shortening functionality to EventMachine-based applications. 

Usage
-----

### Quick start

```ruby  
    require 'em-shorturl'
    
    EM.run do
      request = EM::ShortURL.shorten('http://google.com')
      request.callback { |url, request| puts "Short URL: #{url}" }
      request.errback { |error, request| puts "Received error: #{error}" }
    end
```

### Bitly Basic Authentication Example

```ruby
    require 'em-shorturl'
    
    EM.run do
      request = EM::ShortURL.shorten('http://google.com', :bitly, :username => 'user', :password => 'pass')
      request.callback { |url, request| puts "Short URL: #{url}" }
      request.errback { |error, request| puts "Received error: #{error}" }
    end
```

### Supported services

* Google
* TinyURL
* Bitly

Drivers
-------

### Google

Google provides both anonymous and authenticated shortening requests. Authenticated requests are tied to the account and statistics is gathered by Google on link usages, which is accessable to the account owner. Currently the driver only accepts API Keys as a means of authenticating (by passing an `:apikey` option), and if no API key is provided anonymous shortening will be used.

### TinyURL

TinyURL is a simple anonymous URL shortening service. There isn't much to it.

### Bitly

Bitly provides only authenticated shortening services. The driver is capable of using either a previously obtained access token which can be passed as the hash `:token => 'API Key'`, or can preform obtaining an access token itself using basic authentication and provided `:username` and `:password` options.

Run tests
---------

The tests for most of the code is a live test of the driver, making a real request to the shortening service and checking the result. Tests are provided to verify login methods via environment variables, which are skipped if the credentials are not supplied.

To run the tests, simply run `rake test`.

Thanks
------

First off, everyone needs to thank the EventMachine crew for building such an awesome library. If you ever pass by one of the authors on the street, buy them a beer.

Second, the authors of em-http-request which this gem relies upon for HTTP fetching. It provides a great interface for creating requests and hasn't given me any issues.

License
-------

See the file `LICENSE`
