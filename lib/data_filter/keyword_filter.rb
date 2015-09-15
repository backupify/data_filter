module DataFilter
  # Used to filter a data item by a search term by seeing if
  # ANY of the data fields' values are similar to the search term
  #
  # @example
  #   object = MyModel.new(text: 'hello world', name: 'goodbye', phrase: 'yo')
  #   filter = DataFilter::KeywordFilter.new([:name, :phrase], 'hello')
  #   filter.call(object)
  #   # => nil
  class KeywordFilter
    # @param field_syms [Array<Symbol>] a collection of all of the data
    #   methods we want to inspect when filtering
    # @param search_term [String] the value we want to use when filtering
    #   the data item
    def initialize(field_syms, search_term)
      @field_syms = field_syms
      @search_term = search_term
    end

    # Filters the item
    #
    # @param item [Comparable] the item we want to filter
    # @return [Object] the original data item
    def call(item)
      item if @field_syms.any? { |s| match?(item, s) }
    end

    private

    # :nodoc:
    def match?(item, field_sym)
      item.respond_to?(field_sym) &&
        DataFilter::LikeFilter.new(field_sym, @search_term).call(item)
    end
  end
end
