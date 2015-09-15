# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bank_slip/version'

Gem::Specification.new do |spec|
  spec.name          = "bank_slip"
  spec.version       = BankSlip::VERSION
  spec.authors       = ["Marco Moura"]
  spec.email         = ["marco.moura@gmail.com"]

  spec.summary       = %q{Bank Slip for Municipal Collection Document.}
  spec.description   = %q{Generate Bank Slip for Municipal Collection Document.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.9"
  spec.add_dependency "barby"
  spec.add_dependency "prawn"
end
