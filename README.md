# DataFilter

an extensible DSL for filtering data sets

## Installation

```rb
gem install data_filter
```

## Usage

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
  add_filter -> (user) { user.student || user.age > 25 }
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

