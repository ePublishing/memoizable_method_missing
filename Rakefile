require 'rake'
require 'echoe'
require 'rake/rdoctask'
require 'spec/rake/spectask'

task :default => :gem

Echoe.new("memoizable_method_missing") do |s|
  s.author = "David McCullars"
  s.project = "memoizable_method_missing"
  s.email = "dmccullars@ePublishing.com"
  s.url = "http://github.com/ePublishing/memoizable_method_missing"
  sdocs_host = "http://rdoc.info/github/ePublishing/memoizable_method_missing/master/frames"
  s.rdoc_pattern = /README|TODO|LICENSE|CHANGELOG|BENCH|COMPAT|exceptions|behaviors|memoizable_method_missing.rb/
  s.clean_pattern += ["ext/lib", "ext/include", "ext/share", "ext/libmemoizable_method_missing-?.??", "ext/bin", "ext/conftest.dSYM"]
  s.summary = 'Optimize method_missing usage'
end

desc 'generate API documentation to doc/rdocs/index.html'
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'doc/rdocs'
  rd.main = 'README.rdoc'
  rd.rdoc_files.include 'README.rdoc', 'CHANGELOG', 'lib/**/*.rb'
  rd.rdoc_files.exclude '**/string_ext.rb', '**/net_https_hack.rb'
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.options << '--all'
  rd.options << '--fileboxes'
end
