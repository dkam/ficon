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

  spec.add_runtime_dependency 'nokogiri', "~> 1.7"
  spec.add_runtime_dependency 'addressable', "~> 2"
  spec.add_runtime_dependency 'fastimage', "~> 2"
  spec.add_runtime_dependency 'sqlite3', "~> 1"

  spec.add_development_dependency "bundler", "~> 1"
  spec.add_development_dependency "rake", "~> 12"
  spec.add_development_dependency "minitest", "~> 5"
  spec.add_development_dependency "byebug", "~> 9"
end
