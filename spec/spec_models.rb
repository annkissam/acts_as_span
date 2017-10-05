ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :span_models, force: true do |t|
    t.date :start_date
    t.date :end_date
  end
end

class SpanModel < ActiveRecord::Base
  acts_as_span
end
