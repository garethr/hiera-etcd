# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/etcd/version'

Gem::Specification.new do |spec|
  spec.name          = "hiera-etcd"
  spec.version       = Hiera::Etcd::VERSION
  spec.authors       = ["Gareth Rushgrove"]
  spec.email         = ["gareth@morethanseven.net"]
  spec.description   = %q{Hiera backend for etcd}
  spec.summary       = %q{etcd is a highly-available key value store for shared configuration and service discovery. Hiera-etcd provides a Hiera backend which allows for specifying multiple etcd paths from which data can be collected and easily inserted into Puppet manifests.}
  spec.homepage      = "https://github.com/garethr/hiera-etcd"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
