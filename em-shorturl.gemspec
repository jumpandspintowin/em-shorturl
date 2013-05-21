require "em-shorturl/version"

Gem::Specification.new do |s|
    s.name          = 'em-shorturl'
    s.version       = EM::ShortURL::VERSION
    s.authors       = ['Nik Johnson']
    s.email         = ['nikjohnson08@gmail.com']
    s.summary       = 'An EventMachine module for shortening urls'

    s.files         = Dir["lib/**/*.rb"]
    s.test_files    = Dir["test/**/*.rb"]
    s.require_path  = 'lib'

    s.add_dependency 'em-http-request'
end
