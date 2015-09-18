require 'test_helper'

module DataFilter
  class RangeFilterTest < Minitest::Spec
    def assert_match(item_count)
      data = OpenStruct.new(item_count: item_count)
      assert_equal data, @f.call(data)
    end

    def assert_filter(item_count)
      data = OpenStruct.new(item_count: item_count)
      assert_equal nil, @f.call(data)
    end

    it "gracefully handles items that don't respond to the filter sym" do
      assert_equal nil, DataFilter::RangeFilter.new(:hello).call(nil)
    end

    describe 'no floor or ceiling' do
      before do
        @f = DataFilter::RangeFilter.new(:item_count)
      end

      it 'always matches fields' do
        assert_match 3
      end
    end

    describe 'floor but no ceiling' do
      before do
        @f = DataFilter::RangeFilter.new(:item_count, floor: 2)
      end

      it 'matches things above the floor' do
        assert_match 3
      end

      it 'matches things equal to the floor' do
        assert_match 2
      end

      it 'filters things under the floor' do
        assert_filter 1
      end
    end

    describe 'ceiling but no floor' do
      before do
        @f = DataFilter::RangeFilter.new(:item_count, ceiling: 2)
      end

      it 'matches things under the ceiling' do
        assert_match 1
      end

      it 'matches things equal to the ceiling' do
        assert_match 2
      end

      it 'filters things above the ceiling' do
        assert_filter 3
      end
    end

    describe 'both ceiling and floor' do
      before do
        @f = DataFilter::RangeFilter.new(:item_count, floor: 1, ceiling: 3)
      end

      it 'matches things between the floor and ceiling' do
        assert_match 2
      end

      it 'matches things equal to the floor' do
        assert_match 1
      end

      it 'matches things equal to the ceiling' do
        assert_match 3
      end

      it 'filters things below the floor' do
        assert_filter 0
      end

      it 'filters things above the ceiling' do
        assert_filter 4
      end
    end

    describe 'nil default' do
      it 'treats nil like the nil default' do
        @f = DataFilter::RangeFilter.new(:item_count, floor: 1, nil_default: 0)
        assert_filter 0

        @f = DataFilter::RangeFilter.new(:item_count, floor: 1, nil_default: 0)
        assert_match 2
      end
    end
  end
end
