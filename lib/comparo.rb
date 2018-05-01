#!/usr/bin/env ruby

require 'digest/md5'

module Comparo

# -----------------------------------------------------------------------------
# Main API
# -----------------------------------------------------------------------------
  
  def compare(dir_a, dir_b)
    a = generate_lookup_table(dir_a)
    b = generate_lookup_table(dir_b)
    filename = "dummy"
    print "These are only in A\n"
    write_results(filename, only_in_first(a, b), [a])
    print "These are only in B\n"
    write_results(filename, only_in_first(b, a), [b])
    print "These are in both \n"
    write_results(filename, in_both(a, b), [a, b])
  end
  
  def write_results(filename, keyset, lookup_tbls)
    keyset.each do |key|
      lookup_tbls.each do |tbl|
        write_result(filename, tbl[key])
      end
    end
  end
  
  def write_result(filename, lines)
    lines.each do |line|
      print line + "\n"
    end
  end

# -----------------------------------------------------------------------------
# Set Operations
# -----------------------------------------------------------------------------

  def in_both(first, second)
    first.keys & second.keys
  end

  def only_in_first(first, second)
    first.keys - second.keys
  end

# -----------------------------------------------------------------------------
# Lookup Table building
# -----------------------------------------------------------------------------

  def generate_lookup_table(dir_path)
    lookup_tbl = {}
    get_filenames(dir_path).each do |filename|
      path = dir_path + filename
      current = File.read(path)
      lookup_tbl = update_table(lookup_tbl, get_hash(current), path)
    end
    lookup_tbl
  end


  def update_table(table, hash, filepath)
    case table.has_key?(hash)
      when true
        table[hash].push(filepath)
      when false
        table[hash] = [filepath]
    end
    table
  end

# -----------------------------------------------------------------------------
# Helpers/Aux functions
# -----------------------------------------------------------------------------

  def get_filenames(dir)
    Dir.entries(dir).select {|f| !File.directory? f}
  end

  def get_hash(file)
    Digest::MD5.digest file
  end

  module_function :write_result, :write_results, :get_filenames,
                  :only_in_first, :in_both, :get_hash, :update_table,
                  :generate_lookup_table, :compare
end

# -----------------------------------------------------------------------------
# Script Entry Point
# -----------------------------------------------------------------------------

if __FILE__ == $0
  Comparo.compare ARGV[0], ARGV[1]
end
