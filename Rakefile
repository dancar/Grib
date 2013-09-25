require 'rake/testtask'

require File.expand_path("../lib/grib/version", __FILE__)

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.test_files = FileList['test/test_*.rb']
  # t.test_files = FileList['spec/*_spec.rb']
  # t.test_files = FileList['spec/spec_*.rb']
  # t.libs << 'spec'
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Build the gem"
task :build do
  system "gem build grib.gemspec"
end

task :gem => :build do
  system "gem uninstall -a grib"
  system "gem install grib-#{Grib::VERSION}.gem"
end