require 'rubygems'
require 'rubygems/specification'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
 
GEM = "acts_as_span"
GEM_VERSION = "0.0.4"
SUMMARY = "Adds date range methods to ActiveRecord Models"
AUTHOR = "Eric Sullivan"
EMAIL = "eric.sullivan@annkissam.com"
HOMEPAGE = "http://www.annkissam.com"
 
spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = SUMMARY
  s.require_paths = ['lib']
  s.files = FileList["[A-Z]*", "{lib,rails}/**/*"]
  
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  s.add_dependency('activerecord', '>= 0')
end
 
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  #t.spec_opts = %w(-fs --color)
  t.spec_opts = %w(--color)
end
  
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
 
desc "Install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end
 
desc "Create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

#rake make_spec
#rake gem
#rake install

namespace :svn do
  desc 'Add all new files to svn'
  task :add_all do
    #From http://lukewarmtapioca.com/2005/06/01/adding-all-new-files-with-svn/
    system('svn status | grep "^\?" | awk \'{print $2}\' | xargs svn add')
  end
  
  desc 'Remove all missing files from svn' 
  task :delete_missing do
    system('svn status | grep "^!" | awk \'{print $2}\' | xargs svn rm')
  end
  
  desc 'add new files and remove missing ones'
  task :update do
    Rake::Task['svn:add_all'].execute
    Rake::Task['svn:delete_missing'].execute 
  end
end

task :commit do
  Rake::Task['make_spec'].execute
  Rake::Task['gem'].execute
  Rake::Task['install'].execute
  Rake::Task['svn:add_all'].execute
  Rake::Task['svn:delete_missing'].execute
end

namespace :spec do
  desc "run specs against multiple versions of rails"
  task :all do
    Dir["Gemfile-*"].sort.each do |gemfile|
      next if gemfile =~ /.lock/
      
      puts "* running specs under #{gemfile} ..."
      gemfile_lock = "#{gemfile}.lock"
      
      FileUtils.rm_f "Gemfile"
      FileUtils.rm_f "Gemfile.lock"
      
      FileUtils.cp gemfile, "Gemfile"
      
      if FileTest::exist?(gemfile_lock)
        FileUtils.cp gemfile_lock, "Gemfile.lock"
      else
        system("bundle install") || raise("could not bundle #{gemfile}")
        FileUtils.cp "Gemfile.lock", gemfile_lock
      end
      
      system("bundle exec spec spec")
      
      FileUtils.rm_f "Gemfile"
      FileUtils.rm_f "Gemfile.lock"
    end
  end
end