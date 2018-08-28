require 'simplecov'
require 'codecov'
require 'find'

# Get the code coverage in html for local viewing
# and in JSON for CI codecov
if ENV['CI'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

# Below is code who's sole purpose is to avoid having to change the require 'openstudio' statement every
# time you do a fresh install of RubyMine and openstudio-standards (which happens a lot for some of us).
# This only applies when using the RubyMine debugger that seems to have issues finding 'openstudio'.
require 'find'
os_loc = nil
# This is the pattern that will be searched
os_dir_look = '/Ruby/openstudio'
# Start at the top directory and cycle through everything
Find.find('/') do |path|
  # if you find /Ruby/openstudio then note it's location and break the loop
  if /#{os_dir_look}/.match(path)
    os_loc = path
    break
  end
end

#If you didn't find anything go back to 'openstudio'
os_loc = 'openstudio' if os_loc.nil?

# Ignore some of the code in coverage testing
SimpleCov.start do
  add_filter '/.idea/'
  add_filter '/.yardoc/'
  add_filter '/data/'
  add_filter '/doc/'
  add_filter '/docs/'
  add_filter '/pkg/'
  add_filter '/test/'
  add_filter '/hvac_sizing/'
  add_filter 'version'  
end

$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)
require 'minitest/autorun'
if ENV['CI'] == 'true'
  require 'minitest/ci'
else
  require 'minitest/reporters'
end

#require 'openstudio'
# Use the new location for the require statement
require os_loc
require 'openstudio/ruleset/ShowRunnerOutput'
require 'json'
require 'fileutils'

# Require local version instead of installed version for developers
begin
  require_relative '../../lib/openstudio-standards.rb'
  puts 'DEVELOPERS OF OPENSTUDIO-STANDARDS: Requiring code directly instead of using installed gem.  This avoids having to run rake install every time you make a change.' 
rescue LoadError
  require 'openstudio-standards'
  puts 'Using installed openstudio-standards gem.' 
end

# Format test output differently depending on whether running
# on CircleCI, RubyMine, or terminal
if ENV['CI'] == 'true'
  puts "Saving test results to #{Minitest::Ci.report_dir}"
else
  if ENV["RM_INFO"]
    Minitest::Reporters.use! [Minitest::Reporters::RubyMineReporter.new]
  else
    Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
  end
end

