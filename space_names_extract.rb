require 'fileutils'
require 'json'
require 'csv'

in_file = './space_types.json'
in_info = JSON.parse(File.read(in_file))
out_info = []
in_info['tables']['space_types']['table'].each do |in_seg|
  out_seg = [in_seg["building_type"].to_s, in_seg["space_type"].to_s, in_seg["ventilation_standard"].to_s,  in_seg["occupancy_schedule"].to_s, in_seg["ventilation_per_area"].to_f, in_seg["occupancy_per_area"]]
  out_info << out_seg
end
CSV.open("./space_names.csv", "w") do |csv|
  out_info.each do |out_seg|
    csv << out_seg
  end
end