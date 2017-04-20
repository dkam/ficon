# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ficon/version'

Gem::Specification.new do |spec|
  spec.name          = "ficon"
  spec.version       = Ficon::VERSION
  spec.authors       = ["Dan Milne"]
  spec.email         = ["d@nmilne.com"]
  spec.summary       = %q{Find website icons}
  spec.description   = %q{Ficon finds icons for websites and optionally, the best icon}
  spec.homepage      = "https://github.com/dkam/ficon"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'addressable'
  spec.add_runtime_dependency 'fastimage'
  spec.add_runtime_dependency 'sqlite3'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "byebug"
end
