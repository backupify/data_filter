module DataFilter
  # Used to filter a data item by a set of ranges by seeing if
  # the data field value intersects that range
  #
  # @example with a floor and ceiling
  #   event = MyModel.new(start_time: Date.parse('2001-01-13'), end_time: Date.parse('2002-01-13'))
  #   filter = DataFilter::RangeOverlapFilter
  #     .new(:start_time, :end_time, floor: Date.parse('2000-01-13'), ceiling: Date.parse('2003-01-13'))
  #   filter.call(object)
  #   # => #<MyModel start_time: #<Date '2001-01-13'>, end_time: #<Date '2002-01-13'>
  class RangeOverlapFilter
    # @param start_sym [Symbol] the range start to filter on
    # @param end_sym [Symbol] the range end to filter on
    # @param floor [Comparable] the range beginning we want to filter the data
    #   item by
    # @param ceiling [Comparable] the range end we want to filter the data item
    #   by
    # @param nil_default [Comparable] the value to use if the data item has no
    #   field value
    def initialize(start_sym, end_sym, floor: nil, ceiling: nil, nil_default: nil)
      @start_sym   = start_sym
      @end_sym     = end_sym
      @floor       = floor
      @ceiling     = ceiling
      @nil_default = nil_default
    end

    # Filters the item
    #
    # @param item [Comparable] the item we want to filter
    # @return [Object] the original data item
    def call(item)
      if item.respond_to?(@start_sym) && item.respond_to?(@end_sym)
        actual_start = item.public_send(@start_sym)
        actual_start = @nil_default if actual_start.nil?

        actual_end = item.public_send(@end_sym)
        actual_end = @nil_default if actual_end.nil?

        item if in_range?(actual_start, actual_end)
      end
    end

    private

    # :nodoc:
    def in_range?(actual_start, actual_end)
      return true if @floor.nil? && @ceiling.nil?
      return false if actual_start.nil? || actual_end.nil?

      # TODO should this sort the start and end?
      # by default Ranges like (2..0) will have no elements
      actual_range = (actual_start..actual_end)

      if @floor.nil?
        actual_range.include?(@ceiling) || actual_range.max <= @ceiling
      elsif @ceiling.nil?
        actual_range.include?(@floor) || actual_range.min >= @floor
      else
        overlaps?((@floor..@ceiling), actual_range)
      end
    end

    # Snipped from ActiveSupport
    def overlaps?(range_a, range_b)
      range_a.include?(range_b.first) || range_b.include?(range_a.first)
    end
  end
end
