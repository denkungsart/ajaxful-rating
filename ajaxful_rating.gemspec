# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ajaxful_rating/version'

Gem::Specification.new do |spec|
  spec.name          = "ajaxful_rating"
  spec.version       = AjaxfulRating::VERSION
  spec.authors       = ["Edgar J. Suarez", "Denis Odorcic"]
  spec.email         = ["edgar.js@gmail.com", "denis.odorcic@gmail.com"]

  spec.summary       = "Provides a simple way to add rating functionality to your application."
  spec.description   = "Provides a simple way to add rating functionality to your application."
  spec.homepage      = "http://github.com/edgarjs/ajaxful-rating"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
