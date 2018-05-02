task default: %w[test]

task :build do
  ruby "test/test.rb"
end

task :clean do
  sh "rm out/*"
end

task :test do
  ruby "test/test.rb"
end

task :run do
  sh "ruby lib/comparo.rb -a test/data/dir_a/ -b test/data/dir_b/ -o out/"
end

task :doc do
  sh "rdoc lib"
end
