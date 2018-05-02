require 'optparse'
require 'digest/md5'
require 'json'
require 'rdoc'

module Comparo

# -----------------------------------------------------------------------------
# Main API
# -----------------------------------------------------------------------------
  
  # The main entrypoint to the Comparo program. Runs the comparison
  # and writes results to a file.
  #
  #   Comparo.run({:a => 'path', :b => 'to'. :out => 'dirs'})
  #
  # Params
  # - *args* - A Hash containing key/vals for :a, :b, :out
   
  def run(args)
    dir_a = append_filename(args[:a], "")
    dir_b = append_filename(args[:b], "")
    dir_out = append_filename(args[:out], "")
    results = compare(args[:a], args[:b])
    process_results(args[:out], results)
  end
  

  # Runs the comparison and returns results
  #
  #   Comparo.compare('path/to/dir/a', 'path/to/dir/b')
  #
  # Params
  # - *a_dir* - A String representing the path to a directory
  # - *b_dir* - A String representing the path to a directory
  #
  # Returns
  # - A Hash with the three sets of keys and two tables of the form:
  #
  #     {
  #       :a_only => [keys, only, in, a],
  #       :b_only => [keys, only, in, b],
  #       :common => [keys, in, a, and, b],
  #       :tbl_a => {lookup_tbl => a},
  #       :tbl_b => {lookup_tbl => b}
  #     }
  #

  def compare(a_dir, b_dir)
    # Generate the lookup tables for each directory
    a = generate_lookup_table(a_dir)
    b = generate_lookup_table(b_dir)
   
    # Return a map of the keysets and tables 
    {
      :a_only => only_in_first(a, b),
      :b_only => only_in_first(b, a),
      :common => in_both(a, b),
      :tbl_a => a,
      :tbl_b => b
    }
  end

  # Processes a Results hash, leading to results being written
  # to disk
  #
  #   Comparo.process_results({results=>hash})
  #
  # Params
  # - *out_dir* - A String representing the path to a directory
  # - *results* - A Hash in the form of the output from Comparo.run
  #
  # Returns
  # - :ok - Symbol representing successful completion

  def process_results(out_dir, results)
    a = results[:tbl_a]
    b = results[:tbl_b]    
    
    # Write out the results
    process_result(out_dir, "a_only", results[:a_only], [a])
    process_result(out_dir, "b_only", results[:b_only], [b])
    process_result(out_dir, "common", results[:common], [a, b])
    :ok
  end
  
  # Processes a single result keyset, leading to results being written to disk
  #
  #   Comparo.process_result('path/to/dir', 'filename', [key, set], [lookup, tbls])
  #
  # Params
  # - *out_dir* - A String representing the path to a directory
  # - *filename* - A String representing the intended filename to write
  # - *keyset* - The List of keys 
  # - *tbls* - The List of lookup tables containing the values for keys in the keyset
  #
  # Returns
  # - :ok - Symbol representing successful completion

  
  def process_result(out_dir, filename, keyset, tbls)
    filepath = append_filename(out_dir, filename)
    write_results(filepath, keyset, tbls)
    :ok
  end

# -----------------------------------------------------------------------------
# Dealing with Files
# -----------------------------------------------------------------------------
  
  # Writes the filenames into a specified file based on the values extracted from
  # the keyset
  #
  #   Comparo.write_results('path/to/file', [key, set], [lookup, tbls])
  #
  # Params
  # - *filepath* - A String representing the path to a file
  # - *keyset* - The set of keys (list) for the given result
  # - *lookup_tbls* - The lookup tables containing the values for keys in the keyset
  #
  # Returns
  # - :ok - Symbol representing successful completion

  def write_results(filepath, keyset, lookup_tbls)
    File.open(filepath, 'w') { |file|
      keyset.each do |key|
        lookup_tbls.each do |tbl|
          write_result(file, tbl[key])
        end
      end
    }
    :ok
  end

  # Write a list of values to a file with newline delimiters
  #
  #   Comparo.write_result('path/to/file', [lines])
  #
  # Params
  # - *filepath* - A String representing the path to a file
  # - *lines* - A List of String lines to be written to the file
  #
  # Returns
  # - :ok - Symbol representing successful completion

  def write_result(file, lines)
    lines.each do |line|
      file.write(line + "\n")
    end
    :ok
  end

  # Handled the condition that the filepath provided does
  # not have a trailing '/' and concatenates the dir and filename
  #
  #   Comparo.append_filename('path/to/dir', 'filename')
  #
  # Params
  # - *dir* - A String representing the path to a directory
  # - *filename* - The String filename to be appended to the dir path
  #
  # Returns
  # - A String representing the filepath
  
  def append_filename(dir, filename)
    case dir.end_with?("/")
      when true
        dir + filename
      when false
        dir + "/" + filename
    end
  end

  # Gets a list of filenames in a directory omitting directory names
  #
  #   Comparo.get_filenames('path/to/dir')
  #
  # Params
  # - *dir* - A String representing the path to a directory
  #
  # Returns
  # - A List of String filenames


  def get_filenames(dir)
    Dir.entries(dir).select {|f| !File.directory? f}
  end

  # Gets the MD5 digest/hash of a file
  #
  #   Comparo.get_hash(file)
  #
  # Params
  # - *file* - The contents of a file from the filesystem
  #
  # Returns
  # - A String representing the hash of the given file


  def get_hash(file)
    Digest::MD5.digest file
  end

# ----------------------------------------------------------------------------- 
# Set Operations
#
# Those functions which do set operations on Hash keysets
# -----------------------------------------------------------------------------
 
  # Gets the intersection keyset based on two Hash data structures
  #
  #   Comparo.in_both({:hash => 'a'}, {:hash =? 'b'})
  #
  # Params
  # - *first* - A Hash
  # - *second* - A Hash
  #
  # Returns
  # - A list of keys which are common to both Hashes
   
  def in_both(first, second)
    # Finding the intersection
    first.keys & second.keys
  end

  # Gets the left-hand keyset based on two Hash data structure
  #
  #   Comparo.only_in_first({:hash => 'a'}, {:hash =? 'b'})
  #
  # Params
  # - *first* - A Hash
  # - *second* - A Hash
  #
  # Returns
  # - A list of keys which only exist in the first Hash

  def only_in_first(first, second)
    # Those only in the left hand set
    first.keys - second.keys
  end

# -----------------------------------------------------------------------------
# Lookup Table building
# ----------------------------------------------------------------------------- 

  # Generates a table of filehash => filepath, key value pairs
  #
  #   Comparo.generate_lookup_table('path/to/dir')
  #
  # Params
  # - *dir_path* - A String representing the path to a directory
  #
  # Returns
  # - A Hash containing filehash => filepath, key => value pairs

  def generate_lookup_table(dir_path)
    lookup_tbl = {}
    get_filenames(dir_path).each do |filename|
      path = dir_path + filename
      hash = get_hash(File.read(path))
      lookup_tbl = update_table(lookup_tbl, hash, path)
    end
    lookup_tbl
  end

  # Updates the Lookup table with new filepaths for a given key
  # Creates a new list if the key isn't already present in the table
  # and appends the current filepath to the list if the key is present.
  #
  #   Comparo.update_table({'filehash' => 'filepath'}, 'filehash', 'filepath')
  #
  # Params
  # - *table* - A Hash containing filehash => filepath, key => value pairs
  # - *hash* - A String representing the hash of a file
  # - *filepath* - A String representing the path to the file
  #
  # Returns
  # - A Hash 'table' with a new entry added

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
                  :generate_lookup_table, :append_filename, :compare,
                  :run, :process_results, :process_result
end

# -----------------------------------------------------------------------------
# The Entry Point to the script & parsing options
# -----------------------------------------------------------------------------

module Parser

  # Parses arguments from the command line
  #
  #   Parser.parse_args()
  #
  # Returns
  # - A Hash of parsed args

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
  Comparo.run(Parser.parse_args())
end
