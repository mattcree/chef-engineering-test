require 'optparse'
require 'digest/md5'
require 'json'

module Comparo

# -----------------------------------------------------------------------------
# Main API
# -----------------------------------------------------------------------------
 
  def compare(args)
    a = generate_lookup_table(args[:a])
    b = generate_lookup_table(args[:b])
    out_dir = args[:out]
    
    a_only_file = append_filename(out_dir, "a_only")
    write_results(a_only_file, only_in_first(a, b), [a])

    b_only_file = append_filename(out_dir, "b_only")
    write_results(b_only_file, only_in_first(b, a), [b])

    common_file = append_filename(out_dir, "common")
    write_results(common_file, in_both(a, b), [a, b])
  end
 
# -----------------------------------------------------------------------------
# Dealing with Files
# -----------------------------------------------------------------------------
  
  def write_results(filepath, keyset, lookup_tbls)
    File.open(filepath, 'w') { |file|
      keyset.each do |key|
        lookup_tbls.each do |tbl|
          write_result(file, tbl[key])
        end
      end
    }
  end

  def write_result(file, lines)
    lines.each do |line|
      file.write(line + "\n")
    end
  end

  def append_filename(dir, filename)
    case dir.end_with?("/")
      when true
        dir + filename
      when false
        dir + "/" + filename
    end
  end

  def get_filenames(dir)
    Dir.entries(dir).select {|f| !File.directory? f}
  end

  def get_hash(file)
    Digest::MD5.digest file
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
      hash = get_hash(File.read(path))
      lookup_tbl = update_table(lookup_tbl, hash, path)
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
# Static Functions(?)
# -----------------------------------------------------------------------------

  module_function :write_result, :write_results, :get_filenames,
                  :only_in_first, :in_both, :get_hash, :update_table,
                  :generate_lookup_table, :compare, :append_filename
end

# -----------------------------------------------------------------------------
# The Entry Point to the script & parsing options
# -----------------------------------------------------------------------------

module Parser
  def parse_args

    options = {}

    OptionParser.new do |parser|

      parser.banner = "Usage: comparo.rb [options]"

      parser.on("-a", "--directory-a STRING", String, "A directory path") do |a|
        options[:a] = a
      end

      parser.on("-b", "--directory-b STRING", String, "A directory path") do |b|
        options[:b] = b
      end

      parser.on("-o", "--output-dir STRING", String, "Output directory path") do |o|
        options[:out] = o
      end

    end.parse!

    options

  end
  
  module_function :parse_args  

end

# -----------------------------------------------------------------------------
# Script Entry Point
# -----------------------------------------------------------------------------

if __FILE__ == $0
  ARGV << '-h' if ARGV.empty?
  Comparo.compare(Parser.parse_args())
end
