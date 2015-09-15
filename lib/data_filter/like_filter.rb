module DataFilter
  # Used to filter a data item by a search term by seeing if
  # the data field value is similar to the search term
  #
  # @example
  #   object = MyModel.new(text: 'hello world!')
  #   filter = DataFilter::LikeFilter.new(:text, 'hello')
  #   filter.call(object)
  #   # => #<MyModel text: 'hello world'>
  class LikeFilter
    # @param field_sym [Symbol] name of the data method we want
    #   to filter
    # @param search_term [String] the value we want to use when
    #   filtering the data item
    def initialize(field_sym, search_term)
      @field_sym = field_sym
      @search_term = search_term
    end

    # Filters the item
    #
    # @param item [Object] the item we want to filter
    # @return [Object, nil] the original data item
    def call(item)
      if item.respond_to?(@field_sym) &&
        match?(item.public_send(@field_sym), @search_term)
        item
      end
    end

    private

    # :nodoc:
    def match?(actual, search_term)
      case actual
      when Hash
        match?(actual.values.flatten, search_term)
      when Array
        actual.any? {|item| match?(item, search_term)}
      when String
        regexp =
          normalize(search_term, true)
            .split(' ')
            .map {|term| Regexp.escape(term)}
            .join('|')
            .insert(0, '(')
            .insert(-1, ')')
        normalize(actual, false).match(/#{regexp}/i)
      end
    end

    def normalize(str, use_cache = false)
      if use_cache
        @normalize_cache ||= {}
        @normalize_cache[str] ||= str.gsub(/[^\w\s]/, ' ')
      else
        str.gsub(/[^\w\s]/, ' ')
      end
    end
  end
end
