require 'csv'
require 'fileutils'
require 'json'

file_name_csv = './BTAPPRE1980_spacetype_ventilation.csv'
file_name_json = './space_types.json'
arr_of_rows = CSV.read(file_name_csv)
space_type_in = JSON.parse(File.read(file_name_json))
space_type_info = space_type_in["tables"]["space_types"]["table"]
space_type_info.each do |space_type|
  if space_type["building_type"] == "Space Function"
    vent_rate = arr_of_rows.select {|row| row[0].to_s.upcase == space_type["space_type"].to_s.upcase}
    space_type["ventilation_per_area"] = vent_rate[0][1].to_f
  end
end

space_type_in["tables"]["space_types"]["table"] = space_type_info
out_file_name = './space_types_mod.json'
File.open(out_file_name, "w") do |f|
  f.write(JSON.pretty_generate(space_type_in))
end
