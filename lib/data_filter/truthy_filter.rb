module DataFilter
  # Used to filter a data item by whether it is truthy/falsey
  #
  # @example
  #   object = MyModel.new(is_alive: 'false')
  #   filter = DataFilter::TruthyFilter.new(:is_alive)
  #   filter.call(object)
  #   # => nil
  class TruthyFilter
    # @param field_sym [Symbol] the name of the field to filter by
    # @param invert [Boolean] (default: false) set to true if you
    #   would rather match when the field is falsey instead of when
    #   it is truthy
    def initialize(field_sym, invert: false)
      @field_sym = field_sym
      @invert = invert
    end

    # Filters the item
    #
    # @param item [Object] the item we want to filter
    # @return [Object, nil] the original data item
    def call(item)
      if item.respond_to?(@field_sym)
        val = item.public_send(@field_sym)
        is_falsey = is_falsey?(val)
        is_match = (@invert ? is_falsey : !is_falsey)
        if is_match
          item
        end
      end
    end

    private

    # @private
    def is_falsey?(val)
      [false, 'false', 0, nil].include?(val)
    end
  end
end
