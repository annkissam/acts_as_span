# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_span/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_span"
  s.version     = ActsAsSpan::VERSION::STRING
  s.authors     = ["Eric Sullivan"]
  s.email       = ["eric.sullivan@annkissam.com"]
  s.homepage    = "https://github.com/annkissam/acts_as_span"
  s.summary     = ActsAsSpan::VERSION::SUMMARY
  s.description = %q{ActiveRecord model w/ a start_date and an end_date == ActsAsSpan}

  s.rubyforge_project = "acts_as_span"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('activerecord', '>= 3.0.0')
  s.add_dependency('activesupport', '>= 3.0.0')
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'acts_as_fu'
end
