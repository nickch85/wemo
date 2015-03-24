$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "wemo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "wemo"
  s.version     = WeMo::VERSION
  s.authors     = ["Jordan Byron"]
  s.email       = ["jordan.byron@gmail.com"]
  s.homepage    = "https://github.com/jordanbyron/wemo"
  s.summary     = "Ruby WeMo API"
  s.description = "Ruby API for WeMo Devices"

  s.files = Dir["{lib}/**/*"] +
    %w{README.md LICENSE}

  s.add_dependency "playful",     "= 0.1.0.alpha.1"
  s.add_dependency "log_switch",  "0.4.0"
  s.add_dependency "crack",       "~> 0.4.1"
  s.add_dependency "rest-client", "~> 1.6.7"
end
