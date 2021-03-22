# frozen_string_Literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'acts_as_span/version'

Gem::Specification.new do |s|
  s.name        = 'acts_as_span'
  s.version     = ActsAsSpan::VERSION::STRING
  s.authors     = ['Eric Sullivan']
  s.email       = ['eric.sullivan@annkissam.com']
  s.homepage    = 'https://github.com/annkissam/acts_as_span'
  s.summary     = ActsAsSpan::VERSION::SUMMARY
  s.description = 'ActiveRecord model w/ a start_date and an end_date == ActsAsSpan'
  s.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_development_dependency 'bundler', '~> 2.1.4'
  s.add_development_dependency 'has_siblings', '~> 0.2.7'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake', '>= 12.3.3'
  s.add_development_dependency 'ransack'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'sqlite3', '~> 1.4'
  s.add_development_dependency 'temping'

  s.add_runtime_dependency('activerecord', '>= 5.0.0')
  s.add_runtime_dependency('activesupport', '>= 5.0.0')
end
