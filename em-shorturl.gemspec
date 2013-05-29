lib = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "em-shorturl/version"

Gem::Specification.new do |s|
    s.name          = 'em-shorturl'
    s.version       = EventMachine::ShortURL::VERSION
    s.authors       = ['Nik Johnson']
    s.email         = ['nikjohnson08@gmail.com']
    s.summary       = 'An EventMachine module for shortening urls'
    s.description   = s.summary

    s.licenses      = ['Simplified BSD']
    s.homepage      = 'https://github.com/jumpandspintowin/em-shorturl'

    s.files         = Dir["lib/**/*.rb"]
    s.test_files    = Dir["test/**/*.rb"]
    s.require_path  = 'lib'

    s.add_runtime_dependency 'em-http-request', '~> 1.0'
end
