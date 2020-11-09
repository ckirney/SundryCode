require 'json'
require 'fileutils'

in_file_name = "./bps_2017_cities_dist_ord_mod.json"
out_file_name = "./bps_2017_cities_analyse.json"

out_array = []
in_data = JSON.parse(File.read(in_file_name))
in_data["size_dist"].each do |size_class|
  size_class["cities"].each do |city|
    if city["climate"].nil? || city["climate"].to_s.upcase == "NONE"
      next
    else
      out_array << city
    end
  end
end

File.write(out_file_name, JSON.pretty_generate(out_array))