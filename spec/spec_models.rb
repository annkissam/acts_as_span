require 'temping'
require 'has_siblings'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["DEBUG"]

Temping.create :span_model do
  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end

  acts_as_span
end

Temping.create :one_parent_child do
  with_columns do |t|
    t.belongs_to :mama

    t.date :start_date
    t.date :end_date
  end

  acts_as_span

  belongs_to :mama
  has_siblings through: [:mama]

  validates_with ActsAsSpan::NoOverlapValidator, scope: proc { siblings }
  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:mama]
end

Temping.create :two_parent_child do
  with_columns do |t|
    t.belongs_to :mama
    t.belongs_to :papa

    t.date :start_date
    t.date :end_date
  end

  acts_as_span

  belongs_to :mama
  belongs_to :papa
  has_siblings through: [:mama, :papa]

  validates_with ActsAsSpan::NoOverlapValidator, scope: proc { siblings }
  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:mama, :papa]
end

Temping.create :mama do
  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end

  has_many :one_parent_children
  has_many :two_parent_children
end

Temping.create :papa do
  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end

  has_many :one_parent_children
end
