# acts\_as\_span

ActiveRecord model w/ a start\_date and an end\_date == ActsAsSpan

Treat those date spans like the objects they are!

## Getting Started

In your Gemfile:

```ruby
    gem 'acts_as_span'
```

In your model:

```ruby
    class SpanRecord < ActiveRecord::Base
      acts_as_span
    end
```

## Ransack
The status scopes' symbols (e.g. `:current`, `:current_on`, `:expired`) are public:
```ruby
    SpanRecord.span_scopes
    # => [:current, :current_on, :expired, ...]
```

To use these alongside ransack, add them to your `ransackable_scopes` as needed:

```ruby
    class SpanRecord
      acts_as_span
      # ...

      def self.ransackable_scopes
        [:my_scope_1, :my_scope_2] + span_scopes
      end
    end
```

## End Date Propagator
This gem also comes with a service object, `ActsAsSpan::EndDatePropagator`.
Specific usage details are documented in the source code
(`lib/acts_as_span/end_date_propagator.rb`), but for the sake of reference:

### Usage
To recursively propagate end dates to applicable child records:

```ruby
ActsAsSpan::EndDatePropagator.call(
  object,                                 # The object to propagate from
  skipped_classes: [ClassOne, ClassTwo],  # Record types to skip (see below)
)
```

where `skipped_classes` is an array of classes that act as span, but should not
  be propagated to.

Any `ActiveRecord` errors encountered during propagation will be added to
  `object`'s errors.

### Propagation Logic

* A record that `acts_as_span` will propagate its end date if...
  1. The record `acts_as_span`
  1. The end date of its default span is changed (using
   `ActiveRecord::Base#changed?`)
  1. The new end date is not `nil`
* A record will be propagated to if...
  1. The record `acts_as_span`
  1. The record's default span's end date is `nil` or after the source record's
   new end date
  1. The record's class is not among `skipped_classes`
  1. The propagating object is associated with the record via a `has_many`
   relationship with the `dependent` option set to `destroy` or `delete`.

To overwrite what records should be propagated to, override
  `should_propagate_to?` and `children`. To overwrite when records should
  propagate their end date, override `should_propagate_from?`.

## Copyright

Copyright (c) 2011-2021 Annkissam. See LICENSE for details.
