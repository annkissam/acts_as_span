# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_span/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_span"
  s.version     = ActsAsSpan::VERSION::STRING
  s.authors     = ["Eric Sullivan"]
  s.email       = ["eric.sullivan@annkissam.com"]
  s.homepage    = "www.annkissam.com"
  s.summary     = ActsAsSpan::VERSION::SUMMARY
  s.description = %q{start_date and end_date as a span w/ ActiveRecord}

  s.rubyforge_project = "acts_as_span"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency(%q<activerecord>, [">= 3"])
  s.add_dependency('activesupport')
end
