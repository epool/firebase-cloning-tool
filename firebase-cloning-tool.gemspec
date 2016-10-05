# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firebase/cloning/tool/version'

Gem::Specification.new do |spec|
  spec.name          = "firebase-cloning-tool"
  spec.version       = Firebase::Cloning::Tool::VERSION
  spec.authors       = ["epool"]
  spec.email         = ["eduardo.alejandro.pool.ake@gmail.com"]

  spec.summary       = %q{Tool for cloning firebase remote config projects.}
  spec.description   = %q{Tool for cloning firebase remote config projects.}
  spec.homepage      = "https://github.com/epool/firebase-cloning-tool"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'capybara',            '~> 2.7.1'
  spec.add_dependency 'selenium-webdriver',  '~> 2.53.1'
  spec.add_dependency 'chromedriver-helper', '~> 1.0.0'
  spec.add_dependency 'pry'
  spec.add_dependency 'pry-byebug',          '~> 3.2.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
