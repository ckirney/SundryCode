require 'fileutils'
require 'json'
require 'csv'

csv_out = []

file_name = './space_types.json'
space_info = JSON.parse(File.read(file_name))
space_types = space_info["tables"]["space_types"]["table"]
space_types.each do |space_type|
  csv_out << [
      space_type["building_type"],
      space_type["space_type"],
      space_type["ventilation_standard"],
      space_type["occupancy_per_area"],
      space_type["ventilation_per_area"],
      space_type["occupancy_schedule"],
      space_type["electric_equipment_per_area"],
      space_type["service_water_heating_peak_flow_per_area"],
      space_type["lighting_per_area"]
  ]
end
csv_out_file = "NECB2011_space_type_info.csv"
CSV.open(csv_out_file, "w") do |csv|
  csv << [
      "building_type",
      "space_type",
      "ventilation_standard",
      "occupancy_per_area",
      "ventilation_per_area",
      "occupancy_schedule",
      "electric_equipment_per_area",
      "service_water_heating_peak_flow_per_area",
      "lighting_per_area"
  ]
  csv_out.each do |csv_line|
    csv << csv_line
  end
end