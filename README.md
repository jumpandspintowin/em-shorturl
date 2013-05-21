em-shorturl
===========

EventMachine module for shortening urls. 

Usage
-----

  require 'em-shorturl'
  
  EM.run do
    request = EM::ShortURL.shorten('http://google.com')
    request.callback { |url, request| puts "Short URL: #{url}" }
    request.errback { |error, request| puts "Received error: #{error}" }
  end

Supported Services
------------------
* Google

Run tests
---------

The tests for most of the code is a live test of the driver, making a real request to the shortening service and checking the result.

`rake test`
