Requirements:

Write a program that takes a pair of directories as input and writes out three files as output.

    A file named 'common', which contains files that are identical in both the first and second directories.
    Files 'a_only' and 'b_only', that contains the files that are only in the first directory ('a') and those that are only in the second directory ('b')

A file is considered identical if its contents are byte for byte identical (name, permissions and location don't matter.)

Expect that this will be run on very large directory trees (100,000 files)
