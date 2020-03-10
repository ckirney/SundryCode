require 'fileutils'
require 'json'
require 'csv'

csv_out = []

csv_in_file = './BTAPPRE1980_spacetype_ventilation_2020-03-05_621-2016_occ.csv'
in_json_name = './space_types_old.json'
out_json_name = './space_types.json'

csv_in = CSV.parse(File.read(csv_in_file), headers: false)

space_info = JSON.parse(File.read(in_json_name))
space_types = space_info["tables"]["space_types"]["table"]
space_types.each do |space_type|
  if space_type["space_type"] == "WholeBuilding"
    space_type["ventilation_standard"] = "ASHRAE 62.1-1999 with NECB2011 occupancy rates"
  else
    space_type["ventilation_standard"] = "ASHRAE 62.1-1999 with ASHRAE 62.1-2016 occupancy rates"
  end
  vent_line= csv_in.find {|csv_row| (csv_row[0] == space_type["building_type"]) && (csv_row[1] == space_type["space_type"])}
  space_type["ventilation_per_area"] = vent_line[2].to_f
end
space_info["tables"]["space_types"]["table"] = space_types
File.write(out_json_name, JSON.pretty_generate(space_info))
