require 'minitest/autorun'
require_relative '../lib/comparo'
 
describe Comparo do
 
  describe 'set logic' do
    list_a = {1=>1,2=>2,3=>3}
    list_b = {4=>4,3=>3,5=>5}
    it 'should find intersection' do
      Comparo.in_both(list_a, list_b).must_equal([3])
    end
    it 'should find only in left' do
      Comparo.only_in_first(list_a, list_b).must_equal([1,2])
    end
  end

  describe 'building lookup tables' do
    it 'should find intersection' do
    
    end
    it 'should find only in left' do
   
     end
  end
 
end
