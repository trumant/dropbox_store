# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dropbox_store/version'

Gem::Specification.new do |spec|
  spec.name          = "dropbox_store"
  spec.version       = DropboxStore::VERSION
  spec.authors       = ["Marnix Kok"]
  spec.email         = ["marnixkok+github@gmail.com"]
  spec.description   = %q{Dropbox Store API facade}
  spec.summary       = %q{Simple interface to the Dropbox Store API}
  spec.homepage      = "http://github.com/marnixk/dropbox_store"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
