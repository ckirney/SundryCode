require 'find'
require 'json'
require 'csv'

class Finddir
  dir_look = '/Ruby/openstudio'
  Find.find('/') do |path|
    if /#{dir_look}/.match(path)
      puts path
    end
  end
end