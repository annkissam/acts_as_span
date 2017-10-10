require 'temping'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

Temping.create :span_model do
  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end

  acts_as_span
end
