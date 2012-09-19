# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_span}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Sullivan"]
  s.date = %q{2010-06-23}
  s.email = %q{eric.sullivan@annkissam.com}
  s.files = ["Rakefile", "README.rdoc", "lib/acts_as_span.rb", "rails/init.rb"]
  s.homepage = %q{http://www.annkissam.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Adds date range methods to ActiveRecord Models}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
