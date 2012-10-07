$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spree_temando/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spree_temando"
  s.version     = SpreeTemando::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SpreeTemando."
  s.description = "TODO: Description of SpreeTemando."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency 'temando', '~>0.0.1'
end
