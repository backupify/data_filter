module DataFilter
  # Represents a collection of data filters that can be called on
  # data. Provides a DSL for creating a filter set and only adding
  # filters the filters that you need.
  class FilterSet
    attr_reader :filters

    def initialize
      @filters = []
    end

    # Add a filter to the filter set
    #
    # @param filter [#call]
    #   a callable filter. Can be a proc, lambda, or any object
    #   that responds to #call
    # @return [FilterSet] the amended filter set
    def add_filter(filter)
      @filters << filter
      self
    end

    # Run the filter set on a single data item
    #
    # @param item [Object] some item that we want to pass through all
    #   of the filters in the filter set
    # @return [Object, nil] the original item or nil
    def filter(item)
      @filters.reduce(item) { |i, filter| i if filter.call(i) }
    end

    # Run the filter set on a collection of data items
    #
    # @param items [Enumerable<Object>] collection of items that we want to
    #   pass through all of the filters in the filter set
    # @return [Enumerable<Object>] the filtered results
    def batch(items)
      items.select { |i| filter(i) }
    end

    # A DSL for creating a series of filters that can be called
    #
    # Provides a cleaner way to define a {DataFilter::FilterSet}
    # with a bunch of different filters
    #
    # Conditionally adds filters to the set based on whether or not
    # any valid search terms are provided (useful for Controller params)
    #
    # @example Office365::Mail::MessagesController
    #   filter_set = DataFilter::FilterSet.create do
    #     like_filter :to,        by: params[:to]
    #     like_filter :from,      by: params[:from]
    #     like_filter :cc,        by: params[:cc]
    #     like_filter :bcc,       by: params[:bcc]
    #     like_filter :subject,   by: params[:subject]
    #
    #     keyword_filter [:to, :from, :cc, :bcc, :subject], by: params[:keyword]
    #
    #     range_filter :date, floor: start_date, ceiling: end_date
    #
    #     if params[:has_attachment] === true
    #       range_filter :attachment_count, floor: 1
    #     elsif params[:has_attachment] === false
    #       range_filter :attachment_count, ceiling: 0, nil_default: 0
    #     end
    #   end
    module DSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Initializes a new {DataFilter::FilterSet} using a block.
        # The block conforms to the DSL defined in this method.
        # Delegates undefined messages to the caller's scope.
        #
        # @yield the DSL block
        # @return [DataFilter::FilterSet] the filter set evaluated
        #   with the DSL
        def create(&block)
          original_self = eval 'self', block.binding
          instance = new
          instance.instance_variable_set(:@original_self, original_self)
          instance.instance_eval &block
          instance
        end
      end

      # Adds a {DataFilter::LikeFilter} to the filter set
      #
      # @param field_sym [Symbol] name of the data method we want
      #   to filter
      # @option opts [Object] :by the value we want to use when
      #   filtering the data item, :normalize_regex the regular
      #   expression used to normalize the string
      def like_filter(field_sym, opts = {})
        if opts[:by]
          @filters << LikeFilter.new(field_sym, opts[:by], opts[:normalize_regex])
        end
      end

      # Adds a {DataFilter::PrefixFilter} to the filter set
      #
      # @param field_sym [Symbol] name of the data method we want
      #   to filter
      # @option opts [Object] :by the value we want to use when
      #   filtering the data item
      def prefix_filter(field_sym, opts = {})
        if opts[:by]
          @filters << PrefixFilter.new(field_sym, opts[:by])
        end
      end

      # Adds a {DataFilter::KeywordFilter} to the filter set
      #
      # @param field_syms [Array<Symbol>] a collection of all of the data
      #   methods we want to inspect when filtering
      # @option opts [Object] :by the value we want to use when filtering
      #   the data item
      def keyword_filter(field_syms, opts = {})
        if opts[:by]
          @filters << KeywordFilter.new(field_syms, opts[:by])
        end
      end

      # Adds a {DataFilter::RangeFilter} to the filter set
      #
      # @param field_sym [Symbol] name of the data method we want to
      #  filter
      # @option opts [Comparable] :floor the range beginning we want to
      #   filter the data item by
      # @option opts [Comparable] :ceiling the range end we want to filter
      #   the data item by
      # @option opts [Comparable] :nil_default the value to use if the
      #   data item has no field value
      def range_filter(field_sym, opts = {})
        if opts[:floor] || opts[:ceiling]
          @filters << RangeFilter.new(field_sym, **opts)
        end
      end

      # Adds a {DataFilter::RangeOverlapFilter} to the filter set
      #
      # @param start_sym [Symbol] name of the start field we want to
      #  filter
      # @param end_sym [Symbol] name of the end field we want to
      #  filter
      # @option opts [Comparable] :floor the range beginning we want to
      #   filter the data item by
      # @option opts [Comparable] :ceiling the range end we want to filter
      #   the data item by
      # @option opts [Comparable] :nil_default the value to use if the
      #   data item has no field value
      def range_overlap_filter(start_sym, end_sym, opts = {})
        if opts[:floor] || opts[:ceiling]
          @filters << RangeOverlapFilter.new(start_sym, end_sym, **opts)
        end
      end

      # Adds a {DataFilter::TruthyFilter} to the filter set
      #
      # @param field_sym [Symbol] name of the field to match on
      # @param match [Object] truthy/falsey value to use to determine whether
      #   the filter should match/filter truthy fields or falsey fields
      def truthy_filter(field_sym, match: nil)
        # Skip filter if match is not specified
        return if match.nil?
        if is_falsey?(match)
          @filters << TruthyFilter.new(field_sym, invert: true)
        else
          @filters << TruthyFilter.new(field_sym)
        end
      end

      # Used to support the DSL. Calls out to the parent scope if
      # we receive a message we can't respond to
      def method_missing(sym, *args, &block)
        @original_self.send(sym, *args, &block)
      end

      # Used to support the DSL. Calls out to the parent scope if
      # we receive a message we can't respond to
      def respond_to_missing?(sym, include_all = false)
        @original_self.respond_to?(sym, include_all)
      end

      private


      # TODO DRY up
      def is_falsey?(val)
        [false, 'false'].include?(val)
      end
    end

    include DSL
  end
end
