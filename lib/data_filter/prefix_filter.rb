module DataFilter
  # Used to filter a data item by a prefix by seeing if
  # the data field value starts with the prefix
  #
  # @example
  #   object = MyModel.new(text: 'hello world!')
  #   filter = DataFilter::PrefixFilter.new(:text, 'hello')
  #   filter.call(object)
  #   # => #<MyModel text: 'hello world'>
  class PrefixFilter
    # @param field_sym [Symbol] name of the data method we want
    #   to filter
    # @param prefix [String] the value we want to use when
    #   filtering the data item
    def initialize(field_sym, prefix)
      @field_sym = field_sym
      @prefix = prefix
    end

    # Filters the item
    #
    # @param item [Object] the item we want to filter
    # @return [Object, nil] the original data item
    def call(item)
      if item.respond_to?(@field_sym) &&
        starts_with?(item.public_send(@field_sym), @prefix)
        item
      end
    end

    private

    def starts_with?(actual, prefix)
      actual.match(/\A#{prefix}/i)
    end
  end
end
