require 'temping'
require 'has_siblings'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["DEBUG"]

Temping.create :spannable_model do
  with_columns do |t|
    t.date :starting_date
    t.date :ending_date

    t.integer :unique_by_date_range
  end
end

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

    # every one-parent child is a favorite! ...by default
    t.boolean :favorite, default: true
  end

  acts_as_span

  def favorite?
    favorite
  end

  belongs_to :mama
  has_siblings through: [:mama]

  validates_with ActsAsSpan::NoOverlapValidator,
    scope: proc { siblings }, instance_scope: proc { favorite? }
  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:mama]
end

Temping.create :one_parent_child_custom do
  with_columns do |t|
    t.belongs_to :mama

    t.date :start_date
    t.date :end_date

    # every one-parent child is a favorite! ...by default
    t.boolean :favorite, default: true
  end

  acts_as_span

  def favorite?
    favorite
  end

  belongs_to :mama
  has_siblings through: [:mama]

  validates_with ActsAsSpan::NoOverlapValidator,
    scope: :siblings, instance_scope: :favorite?, message: 'Custom error message'
  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:mama], message: 'Custom error message'
end

Temping.create :two_parent_child_partial_span_validation do
  with_columns do |t|
    t.belongs_to :mama
    t.belongs_to :papa

    t.date :start_date
    t.date :end_date

  end

  acts_as_span

  belongs_to :mama
  belongs_to :papa

  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:mama], skip_start_date_validation: true
  validates_with ActsAsSpan::WithinParentDateSpanValidator, parents: [:papa], skip_end_date_validation: true
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

  acts_as_span

  has_many :one_parent_children
  has_many :two_parent_children
  has_many :one_parent_child_customs
end

Temping.create :papa do
  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end

  acts_as_span

  has_many :one_parent_children
end

# fulfill association requirements for EndDatePropagator
Temping.create :base do
  has_many :children, dependent: :destroy
  has_many :dogs, dependent: :destroy
  has_many :birds, through: :children
  has_many :tales, dependent: :destroy

  acts_as_span

  with_columns do |t|
    t.date :end_date
    t.date :start_date
  end
end

Temping.create :cat_owner do
  has_many :cats, dependent: :destroy

  acts_as_span

  with_columns do |t|
    t.date :start_date
    t.date :end_date
  end
end

Temping.create :cat do
  belongs_to :cat_owner

  with_columns do |t|
    t.belongs_to :cat_owner
  end
end

Temping.create :other_base do
  has_many :children, dependent: :destroy

  acts_as_span

  with_columns do |t|
    t.date :end_date
    t.date :start_date
  end
end

# has non-standard start_ and end_field names
Temping.create :child do
  belongs_to :base
  belongs_to :other_base
  has_many :birds, dependent: :destroy

  validates_with ActsAsSpan::WithinParentDateSpanValidator,
    parents: [:base]

  validate :not_manually_invalidated

  acts_as_span(
    start_field: :date_of_birth,
    end_field: :emancipation_date,
  )

  with_columns do |t|
    t.date :date_of_birth
    t.date :emancipation_date
    t.string :manual_invalidation
    t.belongs_to :base
  end

  def not_manually_invalidated
    return if manual_invalidation.blank? || manual_invalidation == false

    errors.add(:base, 'Child is bad')
  end
end

Temping.create :dog do
  belongs_to :base

  acts_as_span

  with_columns do |t|
    t.date :start_date
    t.date :end_date
    t.belongs_to :base
  end
end


Temping.create :bird do
  belongs_to :child

  validates_with ActsAsSpan::WithinParentDateSpanValidator,
    parents: [:child]

  acts_as_span

  with_columns do |t|
    t.date :end_date
    t.date :start_date
    t.belongs_to :child
  end
end

Temping.create :tale do
  belongs_to :base

  acts_as_span

  with_columns do |t|
    t.date :end_date
    t.date :start_date
    t.belongs_to :base
  end
end
