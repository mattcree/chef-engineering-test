task default: %w[test]

task :build => [:doc, :test, :run] do
end

task :clean do
  sh "rm out/*"
  sh "rmdir out"
end

task :test do
  ruby "test/test.rb"
end

task :run do
  sh "mkdir -p out"
  sh "ruby lib/comparo.rb -a test/data/dir_a/ -b test/data/dir_b/ -o out/"
end

task :doc do
  sh "rdoc lib"
end

task :cleandoc do
  sh "rm -rf doc"
end
