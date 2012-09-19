# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_span}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Sullivan"]
  s.date = %q{2011-01-13}
  s.email = %q{eric.sullivan@annkissam.com}
  s.files = ["CHANGELOG.rdoc", "Gemfile-2.3", "Gemfile-2.3.lock", "Gemfile-3.0", "Gemfile-3.0.lock", "Rakefile", "README.rdoc", "lib/acts_as_span.rb", "rails/init.rb"]
  s.homepage = %q{http://www.annkissam.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Adds date range methods to ActiveRecord Models}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
  end
end
