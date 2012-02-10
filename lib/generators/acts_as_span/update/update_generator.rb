#Adapted from paperclip...
#https://github.com/thoughtbot/paperclip

require 'rails/generators/active_record'

module ActsAsSpan
  class UpdateGenerator < ActiveRecord::Generators::Base
    desc "Create a migration to add acts_as_span-specific fields to your model. " +
         "The NAME argument is the name of your model"

    def self.source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end

    def generate_migration
      migration_template "migration.rb.erb", "db/migrate/#{migration_file_name}"
    end

    protected

    def migration_name
      "add_acts_as_span_to_#{name.underscore}"
    end

    def migration_file_name
      "#{migration_name}.rb"
    end

    def migration_class_name
      migration_name.camelize
    end
  end
end