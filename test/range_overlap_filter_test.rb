require 'test_helper'

class RangeOverlapFilterTest < Minitest::Spec
  def assert_match(start, _end)
    data = OpenStruct.new(start: start, end: _end)
    assert_equal data, @f.call(data)
  end

  def assert_filter(start, _end)
    data = OpenStruct.new(start: start, end: _end)
    assert_equal nil, @f.call(data)
  end

  describe 'no floor or ceiling' do
    before do
      @f = DataFilter::RangeOverlapFilter.new(:start, :end)
    end

    it 'always matches' do
      assert_match 1, 3
    end
  end

  describe 'floor but no ceiling' do
    before do
      @f = DataFilter::RangeOverlapFilter.new(:start, :end, floor: 2)
    end

    it 'matches if the range straddles the floor' do
      assert_match 1, 3
    end

    it 'matches if the range peak matches the floor' do
      assert_match 1, 2
    end

    it 'matches if the range valley matches the floor' do
      assert_match 2, 3
    end

    it 'filters if the range is entirely below the floor' do
      assert_filter 0, 1
    end

    it 'matches if the range is entirely above the floor' do
      assert_match 3, 4
    end
  end

  describe 'ceiling but no floor' do
    before do
      @f = DataFilter::RangeOverlapFilter.new(:start, :end, ceiling: 3)
    end

    it 'matches if the range straddles the ceiling' do
      assert_match 2, 4
    end

    it 'matches if the range peak matches the ceiling' do
      assert_match 1, 3
    end

    it 'matches if the range valley matches the ceiling' do
      assert_match 3, 5
    end

    it 'matches if the range is entirely below the ceiling' do
      assert_match 0, 1
    end

    it 'filters if the range is entirely above the ceiling' do
      assert_filter 4, 5
    end
  end

  describe 'floor and ceiling' do
    before do
      @f = DataFilter::RangeOverlapFilter.new(:start, :end, floor: 2, ceiling: 5)
    end

    it 'matches if the range straddles the ceiling' do
      assert_match 3, 6
    end

    it 'matches if the range is straddling the floor' do
      assert_match 1, 3
    end

    it 'matches if the range extends past both the ceiling and the floor' do
      assert_match 1, 6
    end

    it 'matches if the range is inside the ceiling and the floor' do
      assert_match 3, 4
    end

    it 'matches if the range is equal to the ceiling and floor' do
      assert_match 2, 5
    end

    it 'matches if the range peak is equal to the floor' do
      assert_match 0, 2
    end

    it 'matches if the range valley is equal to the ceiling' do
      assert_match 5, 6
    end

    it 'filters if the range is entirely below the floor' do
      assert_filter 0, 1
    end

    it 'filters if the range is entirely above the ceiling' do
      assert_filter 6, 7
    end
  end

  describe 'nil default' do
    it 'treats nils as the nil default' do
      @f = DataFilter::RangeOverlapFilter.new(:start, :end, floor: 1, nil_default: 0)
      assert_filter nil, nil
      assert_match nil, 1

      @f = DataFilter::RangeOverlapFilter.new(:start, :end, floor: 1, nil_default: 1)
      assert_match nil, nil
    end
  end
end
