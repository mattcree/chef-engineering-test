require 'minitest/autorun'
require_relative '../lib/comparo'
 
describe Comparo do
 
  describe 'testing a function' do
    it 'should pass' do
      true.must_equal true
    end
  end
 
end
