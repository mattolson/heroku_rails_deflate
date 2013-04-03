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
  gem.description = %Q{This gem is designed for use by Rails applications running on Heroku. For others, the better approach is to use a frontend server such as nginx or Apache. However, the Heroku Cedar stack is no longer fronted by a file server, and there is no automatic provision for gzipping responses. This gem activates Rack::Deflate for all requests. In addition, we serve up the gzipped versions of our precompiled assets, taking advantage of the higher compression ratio used during precompilation, and reducing CPU load at request time.}
  gem.email = "matt@mattolson.com"
  gem.authors = ["Matt Olson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "heroku_rails_deflate #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
