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

## Copyright

Copyright (c) 2011-2021 Annkissam. See LICENSE for details.
