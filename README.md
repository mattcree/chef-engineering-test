
# Comparo

# Description:

A program that takes a pair of directories as input and writes
out three files as output.
* A file named 'common', which contains files that are identical in both the
  first and second directories.
* Files 'a\_only' and 'b\_only', that contains the files that are only in
  the first directory ('a') and those that are only in the second
  directory ('b')

A file is considered identical if its contents are byte for byte identical (name,
permissions and location don't matter.)

## Instructions
### Automated Tasks
* Ensure the following tasks exist and are automated via Makefile or other tool of your choice:
  * clean
    - Removes files in ```out/```
    - ```$ rake clean```
  * test
    - Runs unit tests
    - ```$ rake test```
  * run
    - Runs script with default input as ```test/data/dir_a``` and ```test/data/dir_b``` with the output as ```out/```
    - ```$ rake run```

### Usage

Get help by running the script without args.
  
```
Usage: comparo.rb [options]
    -a, --directory-a STRING         A directory path
    -b, --directory-b STRING         A directory path
    -o, --output-dir STRING          Output directory path

```

Typical usage as follows

```ruby lib/comparo.rb -a test/data/dir_a/ -b test/data/dir_a/ -o out/```

### Assumptions/Caveats

1. There may be copies of the same file in the same directory i.e. two identical files with different names in a directory
2. Only filepaths (relative) are required in output
3. Files are grouped by identity in output
4. 
