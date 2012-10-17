$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spree_temando/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spree_temando"
  s.version     = SpreeTemando::VERSION
  s.authors     = ["Jason Stirk"]
  s.email       = ["jason@reinteractive.net"]
  s.homepage    = "http://github.com/reInteractive/spree_temando"
  s.summary     = "Adds temando shipping support to Spree"
  s.description = "Adds temando shipping support to Spree"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'spree_core', "~> 1.1.1"
  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency 'temando', '~>0.1.0'

  s.add_development_dependency 'rspec', '~> 2.11.0'
  s.add_development_dependency 'faker'
end
