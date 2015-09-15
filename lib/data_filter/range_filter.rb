module DataFilter
  # Used to filter a data item by some range by seeing if
  # the data field value falls within that range
  #
  # @example with a ceiling
  #   object = MyModel.new(created_at: Date.parse('2001-01-13'))
  #   filter = DataFilter::RangeFilter.new(:created_at, ceiling: Date.parse('2003-01-01'))
  #   filter.call(object)
  #   # => #<MyModel created_at: #<Date '2001-01-13'>>
  #
  # @example with a floor
  #   object = MyModel.new(file_count: 300)
  #   filter = DataFilter::RangeFilter.new(:file_count, floor: 1)
  #   filter_return = filter.call(object)
  #   # => #<MyModel file_count: 300>
  #   has_file = filter_return.present?
  #   # => true
  class RangeFilter
    # @param field_sym [Symbol] the field to filter on
    # @param floor [Comparable] the range beginning we want to filter the data
    #   item by
    # @param ceiling [Comparable] the range end we want to filter the data item
    #   by
    # @param nil_default [Comparable] the value to use if the data item has no
    #   field value
    def initialize(field_sym, floor: nil, ceiling: nil, nil_default: nil)
      @field_sym    = field_sym
      @floor        = floor
      @ceiling      = ceiling
      @nil_default  = nil_default
    end

    # Filters the item
    #
    # @param item [Comparable] the item we want to filter
    # @return [Object] the original data item
    def call(item)
      if item.respond_to?(@field_sym)
        actual = item.public_send(@field_sym)
        actual = @nil_default if actual.nil?
        item if in_range?(actual)
      end
    end

    private

    # :nodoc:
    def in_range?(actual)
      return false if actual.nil?
      (@floor.nil? || actual >= @floor) && (@ceiling.nil? || actual <= @ceiling)
    end
  end
end
