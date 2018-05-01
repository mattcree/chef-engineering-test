#!/usr/bin/env ruby

require 'digest/md5'

module Comparo
  
  def compare(dir_a, dir_b)
    a = generate_lookup_table dir_a
    b = generate_lookup_table dir_b

    write_results(only_in_first(a, b), a, "Only in dir_a")
    write_results(only_in_first(b, a), b, "Only in dir_b")
  end
  
  def write_results(keyset, lookup_tbl, message)
    print message + "\n"
    keyset.each do |key|
      print lookup_tbl[key] + "\n"
    end
  end
 
  def in_both(first, second)
    first.keys & second.keys
  end

  def only_in_first(first, second)
    first.keys - second.keys
  end
   
  def generate_lookup_table dir_path
    lookup_tbl = {}
    get_filenames(dir_path).each do |filename|
      path = dir_path + filename
      current = File.read path
      lookup_tbl = update_table(lookup_tbl, get_hash(current), path)
    end
    lookup_tbl
  end 

  def update_table(table, hash, filepath)
    table[hash] = filepath
    table
  end

  def get_filenames dir
    Dir.entries(dir).select {|f| !File.directory? f}
  end

  def get_hash file
    Digest::MD5.digest file
  end

  module_function :write_results, :get_filenames, :only_in_first, :in_both, :get_hash, :update_table, :generate_lookup_table, :compare
end

if __FILE__ == $0
  Comparo.compare ARGV[0], ARGV[1]
end
