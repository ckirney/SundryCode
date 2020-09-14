require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Building Type",
    "Space Type",
    "Lighting (W/ft2)",
    "Outdoor Air Flow Rate (cfm/ft2)",
    "NECB Occupancy (people/1000 ft2)",
    "Space Equipment Electrical Load (W/ft2)",
    "Service Hot Water Flow Rate (US Gal/hr/ft2)",
    "NECB Schedule Table"
]

json_titles = [
    "building_type",
    "space_type",
    "lighting_per_area",
    "ventilation_per_area",
    "occupancy_per_area",
    "electric_equipment_per_area",
    "service_water_heating_peak_flow_per_area",
    "necb_schedule_type"
]

standard_versions = [
    "NECB2015",
    "NECB2011",
    "BTAPPRE1980"
]

spacetype_map_file = "./data/space_type_upgrade_map.json"
spacetype_maps = JSON.parse(File.read(spacetype_map_file))["tables"]["space_type_upgrade_map"]["table"]

workbook = WriteXLSX.new('space_types_with_map.xlsx')
worksheet = workbook.add_worksheet

spacetype_rows = []
standard_version = "NECB2017"
in_file = "./data/space_types_" + standard_version + ".json"
space_types = JSON.parse(File.read(in_file))["tables"]["space_types"]["table"]
col = row = 0
worksheet.write(0, 0, "Standard")
col += 1
col_titles.each do |col_title|
  worksheet.write(row, col, col_title)
  col += 1
end
row += 1
space_types.each do |space_type|
  spacetype_rows = {
      building_type: space_type["building_type"],
      space_type: space_type["space_type"],
      row: row
  }
  col = 0
  worksheet.write(row, col, standard_version)
  col += 1
  json_titles.each do |json_title|
    worksheet.write(row, col, space_type[json_title])
    col += 1
  end
  row += 1
end

standard_versions.each do |standard_version|
  col_home = col + 1
  in_file = "./data/space_types_" + standard_version + ".json"
  space_types = JSON.parse(File.read(in_file))["tables"]["space_types"]["table"]

  row = 0
  worksheet.write(0, col_home, "Standard")
  col = col_home + 1
  col_titles.each do |col_title|
    worksheet.write(row, col, col_title)
    col += 1
  end

  map_building_type = standard_version + "_building_type"
  map_space_type = standard_version + "_space_type"

  space_types.each do |space_type|
    col = col_home
    base_space_types = spacetype_maps.select{|space_type_map| space_type_map[map_building_type] == space_type["building_type"] && space_type_map[map_space_type] == space_type["space_type"]}
    if base_space_types.size == 0
      puts 'hello'
    elsif base_space_types.size == 1
      puts 'hello'
    else
      puts 'hello'
    end
    json_titles.each do |json_title|
      worksheet.write(row, col, space_type[json_title])
      col += 1
    end
    row += 1
  end
end