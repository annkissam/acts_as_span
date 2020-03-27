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
  s.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
          "public gem pushes."
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 2.0.1"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "sqlite3", "~> 1.4"
  s.add_development_dependency "has_siblings", "~> 0.2.7"
  s.add_development_dependency "temping"
  s.add_development_dependency "pry-byebug"

  s.add_runtime_dependency('activerecord', '>= 4.2.0')
  s.add_runtime_dependency('activesupport', '>= 4.2.0')
end
