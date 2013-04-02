# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/heroku_rails_deflate/version'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "heroku_rails_deflate"
  gem.version = HerokuRailsDeflate::Version::STRING
  gem.homepage = "http://github.com/mattolson/heroku_rails_deflate"
  gem.license = "MIT"
  gem.summary = %Q{Activate Rack::Deflate and serve up precompiled, gzipped assets on Heroku}
  gem.description = %Q{Activate Rack::Deflate and serve up precompiled, gzipped assets on Heroku. This allows us to take advantage of higher compression ratios of prezipped files, and reduces CPU load at request time.}
  gem.email = "matt@mattolson.com"
  gem.authors = ["Matt Olson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "heroku_rails_deflate #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
