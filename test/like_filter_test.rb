require 'test_helper'

module DataFilter
  class LikeFilterTest < Minitest::Spec
    it "gracefully handles items that don't respond to the filter sym" do
      assert_equal nil, DataFilter::LikeFilter.new(:hello, 'world').call(nil)
    end

    it 'is case insensitive' do
      filter = DataFilter::LikeFilter.new(:name, 'john')
      el = OpenStruct.new(name: 'John Snow')
      assert_equal el, filter.call(el)
    end

    it 'strips regexp' do
      # Regexp in both filter and data
      # Both get stripped and search is identical to data
      filter = DataFilter::LikeFilter.new(:name, 'b*lbo')
      el = OpenStruct.new(name: 'b*lbo')
      assert_equal el, filter.call(el)

      # Regexp in filter it pass due to special char strip
      # The split parts then fuzzy match properly
      filter = DataFilter::LikeFilter.new(:name, 'b*lbo')
      el = OpenStruct.new(name: 'bilbo')
      refute_equal nil, filter.call(el)

      # Regexp in data it fail due to special char strip
      # The search term does not fuzzy match the split parts
      filter = DataFilter::LikeFilter.new(:name, 'bilbo')
      el = OpenStruct.new(name: 'b*lbo')
      assert_equal nil, filter.call(el)
    end

    it 'ignores extra whitespace' do
      # Extra space in both filter and data
      filter = DataFilter::LikeFilter.new(:name, 'hello  world')
      el = OpenStruct.new(name: 'hello   world')
      assert_equal el, filter.call(el)

      # Extra space in filter
      filter = DataFilter::LikeFilter.new(:name, ' fern  bush')
      el = OpenStruct.new(name: 'fern bush')
      assert_equal el, filter.call(el)

      # Extra space in data
      filter = DataFilter::LikeFilter.new(:name, 'yo dawg')
      el = OpenStruct.new(name: ' yo  dawg ')
      assert_equal el, filter.call(el)
    end

    it 'ignores non-word characters' do
      # Special characters in both filter and data
      filter = DataFilter::LikeFilter.new(:name, 'mr.bean')
      el = OpenStruct.new(name: 'mr,bean')
      assert_equal el, filter.call(el)

      # Special characters in filter
      filter = DataFilter::LikeFilter.new(:name, 'mr.bean')
      el = OpenStruct.new(name: 'mr bean')
      assert_equal el, filter.call(el)

      # Special characters in both filter and data
      filter = DataFilter::LikeFilter.new(:name, 'mr bean')
      el = OpenStruct.new(name: 'mr.bean')
      assert_equal el, filter.call(el)
    end

    it 'does not match if the search term is more specific than the data' do
      filter = DataFilter::LikeFilter.new(:name, 'joshua')
      el = OpenStruct.new(name: 'josh')
      assert_equal nil, filter.call(el)
    end

    it 'matches if the search term is less specific than the data' do
      filter = DataFilter::LikeFilter.new(:name, 'josh')
      el = OpenStruct.new(name: 'joshua')
      assert_equal el, filter.call(el)
    end

    it 'matches if the search term is identical to the data' do
      filter = DataFilter::LikeFilter.new(:name, 'josh')
      el = OpenStruct.new(name: 'josh')
      assert_equal el, filter.call(el)
    end

    it 'handles arrays' do
      filter = DataFilter::LikeFilter.new(:name, 'Array Man')
      el = OpenStruct.new(name: ['Array Man'])
      assert_equal el, filter.call(el)
    end

    it 'handles hashes' do
      filter = DataFilter::LikeFilter.new(:name, 'Super Hash')
      el = OpenStruct.new(name: {:alias => 'Super Hash'})
      assert_equal el, filter.call(el)
    end

    it 'allows custom regex' do
      # email characters in both filter and data
      filter = DataFilter::LikeFilter.new(:from, 'test-user+person@datto.com', /[^\w\s^.^@^-]/)
      el = OpenStruct.new(from: 'test-user+person@datto.com')
      assert_equal el, filter.call(el)
    end

    it 'allows custom regex to be nil' do
      # email characters in both filter and data
      filter = DataFilter::LikeFilter.new(:from, 'Bobs Burgers', nil)
      el = OpenStruct.new(from: 'Bobs Burgers')
      assert_equal el, filter.call(el)
    end
  end
end
