require 'test_helper'

module DataFilter
  class TruthyFilterTest < Minitest::Spec
    describe 'not inverted' do
      before do
        @filter = DataFilter::TruthyFilter.new(:is_alive)
      end

      [true, 'true', 1, 'hello world', Object.new].each do |val|
        it "matches #{val} (#{val.class})" do
          obj = OpenStruct.new(is_alive: val)
          assert_equal obj, @filter.call(obj)
        end
      end

      [false, 'false', nil, 0].each do |val|
        it "filters #{val} (#{val.class})" do
          obj = OpenStruct.new(is_alive: val)
          assert_equal nil, @filter.call(obj)
        end
      end
    end

    describe 'inverted' do
      before do
        @filter = DataFilter::TruthyFilter.new(:is_alive, invert: true)
      end

      [false, 'false', nil, 0].each do |val|
        it "matches #{val} (#{val.class})" do
          obj = OpenStruct.new(is_alive: val)
          assert_equal obj, @filter.call(obj)
        end
      end

      [true, 'true', 1, 'hello world', Object.new].each do |val|
        it "filters #{val} (#{val.class})" do
          obj = OpenStruct.new(is_alive: val)
          assert_equal nil, @filter.call(obj)
        end
      end
    end
  end
end
