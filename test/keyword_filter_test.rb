require 'test_helper'

module DataFilter
  class KeywordFilterTest < Minitest::Spec
    it "gracefully handles items that don't respond to the filter sym" do
      assert_equal nil, DataFilter::KeywordFilter.new([:hello, :goodbye], 'search').call(nil)
    end

    it 'is case insensitive' do
      el = OpenStruct.new(name: 'John Snow')
      assert_equal el, DataFilter::KeywordFilter.new([:name], 'john').call(el)
    end
  end
end
