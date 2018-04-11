
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "allq/version"

Gem::Specification.new do |spec|
  spec.name          = "allq"
  spec.version       = Allq::VERSION
  spec.authors       = ["Jason"]
  spec.email         = ["jaciones@gmail.com"]

  spec.summary       = %q{Ruby library for using AllQ}
  spec.description   = %q{Ruby gem for using AllQ}
  spec.homepage      = "https://github.com/blitline-dev/allq_gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
