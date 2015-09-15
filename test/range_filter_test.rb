require 'test_helper'

module DataFilter
  class RangeFilterTest < Minitest::Spec
    it "gracefully handles items that don't respond to the filter sym" do
      assert_equal nil, DataFilter::RangeFilter.new(:hello).call(nil)
    end
  end
end
