require 'json'
require 'fileutils'

in_file = "./bps_2017_cities_analyse.json"
out_file = "./bps_2017_climate_info.json"

in_json = JSON.parse(File.read(in_file))
out_info = []
climates = in_file.uniq{|city| city["climate"]}
in_json.each do |city|
  puts 'hello'
end