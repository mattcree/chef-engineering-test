require 'minitest/autorun'
require_relative '../lib/comparo'

require 'digest/md5'
require 'set'

describe Comparo do
 
  describe 'set logic' do
    list_a = {1=>1,2=>2,3=>3}
    list_b = {4=>4,3=>3,5=>5}
    it 'should find intersection' do
      expected = [3]
      actual = Comparo.in_both(list_a, list_b)
      actual.must_equal expected
    end
    it 'should find only in left' do
      expected = [1,2]
      actual = Comparo.only_in_first(list_a, list_b)
      actual.must_equal expected
    end
  end

  describe 'generating lookup tables' do
    path_a = 'test/data/test_files/'

    it 'should generate correct num of keys' do
      expected = 2
      actual = Comparo.generate_lookup_table(path_a).keys.length
      actual.must_equal expected
    end
    it 'should generate correct num of values' do
      expected = 3
      actual = Comparo.generate_lookup_table(path_a).values.flatten.length
      actual.must_equal expected
    end
  end
  
  describe 'updating table' do
    it 'should add new value in list' do
      expected = {:key => [:val]}
      actual = Comparo.update_table({}, :key, :val)
      actual.must_equal expected
    end
    it 'should append if val exists' do
      expected = {:key => [:val, :new_val]}
      arg = {:key => [:val]}
      actual = Comparo.update_table(arg, :key, :new_val)
      actual.must_equal expected
    end
  end

  describe 'getting filenames' do
    path_a = 'test/data/test_files'
    it 'should get a list of filenames' do
      expected = ["test_1", "test_2", "test_3"].sort
      actual = Comparo.get_filenames(path_a).sort
      actual.must_equal expected
    end
    it 'should not contain dirs' do
      expected = false
      output = Comparo.get_filenames(path_a)
      actual = output.include?('.') && output.include?('..')
      actual.must_equal expected
    end
  end
 
  describe 'comparing directories' do
    path_a = "test/data/test_files/"
    it 'should have correct num of common hashes' do
      expected = 2
      actual = Comparo.compare(path_a, path_a)[:common].length
      actual.must_equal expected
    end
    it 'should have correct num of common hashes' do
      expected = 2
      actual = Comparo.compare(path_a, path_a)[:common].length
      actual.must_equal expected
    end
  end 
  
  describe 'appending filenames' do
    dir = 'path/to/dir'
    dir_with_slash = dir + '/'
    filename = 'bobby'
    full_path = dir_with_slash + filename

    it 'append filename when trailing slash present' do
      expected = full_path
      actual = Comparo.append_filename(dir_with_slash, filename)
      actual.must_equal expected
    end
    it 'append filename when no trailing slash present' do
      expected = full_path 
      actual = Comparo.append_filename(dir, filename)
      actual.must_equal expected
    end
  end

end
