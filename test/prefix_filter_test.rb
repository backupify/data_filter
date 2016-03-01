require 'test_helper'

module DataFilter
  class PrefixFilterTest < Minitest::Spec
    it "gracefully handles items that don't respond to the filter sym" do
      assert_equal nil, DataFilter::PrefixFilter.new(:hello, 'world').call(nil)
    end

    it 'is case insensitive' do
      filter = DataFilter::PrefixFilter.new(:name, 'johN s')
      el = OpenStruct.new(name: 'John Snow')
      assert_equal el, filter.call(el)
    end

    it 'does not match if the search term is more specific than the data' do
      filter = DataFilter::PrefixFilter.new(:name, 'josh1')
      el = OpenStruct.new(name: 'josh')
      assert_equal nil, filter.call(el)
    end

    it 'does not match if the search term is not at the start of the data' do
      filter = DataFilter::PrefixFilter.new(:name, 'josh')
      el = OpenStruct.new(name: ' josh')
      assert_equal nil, filter.call(el)
    end

    it 'matches if the search term is less specific than the data' do
      filter = DataFilter::PrefixFilter.new(:name, 'jo')
      el = OpenStruct.new(name: 'joshua')
      assert_equal el, filter.call(el)
    end

    it 'matches if the search term is identical to the data' do
      filter = DataFilter::PrefixFilter.new(:name, 'one two')
      el = OpenStruct.new(name: 'one two')
      assert_equal el, filter.call(el)
    end
  end
end
