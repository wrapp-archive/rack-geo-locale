# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "rack-locale"
  s.version     = File.read('VERSION').to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joakim Ekberg"]
  s.email       = ["joakim@wrapp.com"]
  s.homepage    = "https://github.com/wrapp/rack-locale"
  s.summary     = "Rack middleware used to guess the visitors country and language based on GeoIP and HTTP_ACCEPT_LANGUAGE."
  s.description = "Simple Rack middleware for setting the locale.country via GeoIP using the MaxMind GeoIP database, and setting the locale.languages based on the HTTP_ACCEPT_LANGUAGE header."


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "guard-rspec"
  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "geoip"
end
