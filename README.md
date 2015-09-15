# DataFilter

[![Gem Version](https://badge.fury.io/rb/data_filter.svg)](http://badge.fury.io/rb/data_filter)
[![Build Status](https://travis-ci.org/backupify/data_filter.svg)](https://travis-ci.org/backupify/data_filter)
[![Coverage Status](https://coveralls.io/repos/backupify/data_filter/badge.svg?branch=master&service=github)](https://coveralls.io/github/backupify/data_filter?branch=master)

an extensible DSL for filtering data sets

## Installation

```rb
gem install data_filter
```

## Usage

`DataFilter::FilterSet::create` provides a DSL for creating a collection
of filters which can be applied to your data. The DSL is designed to be
controller friendly and will only apply filters if a parameter is specified.
If a filter doesn't do what you need then you can pass any object that responds
to `#call` (e.g. a lambda) to `add_filter`.

```rb
filter_set = DataFilter::FilterSet.create do
  # Fuzzy comparison
  like_filter :name, by: params[:name]

  # Keyword search
  keyword_filter [:gender], by: params[:gender]

  # Match truthy/falsey values
  truthy_filter :student, match: params[:is_student]

  # Check if within range
  range_filter :age, ceiling: params[:max_age]

  # Add a custom filter
  add_filter -> (user) { user if user.student || user.age > 25 }
end

data = [
  User.create(name: 'Josh', age: 26, student: false, gender: :male),
  User.create(name: 'Lauren', age: 25, student: true, gender: :female)
]

# By default data which doesn't match all of the filters will be filtered out
filter_set.call(data)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

