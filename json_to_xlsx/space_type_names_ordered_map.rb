require 'write_xlsx'
require 'json'
require 'fileutils'

standard_versions = [
    "BTAPPRE1980",
    "NECB2011",
    "NECB2015",
    "NECB2017"
]

workbook = WriteXLSX.new('space_types_list_with_info.xlsx')
worksheet = workbook.add_worksheet

in_file = "./data/space_type_upgrade_map.json"
space_type_maps = JSON.parse(File.read(in_file))["tables"]["space_type_upgrade_map"]["table"]

col = 0
standard_versions.each do |standard_version|
  map_space_type = standard_version + "_space_type"
  map_building_type = standard_version + "_building_type"
  row = 0
  in_file = "./data/space_types_" + standard_version + ".json"
  space_types = JSON.parse(File.read(in_file))["tables"]["space_types"]["table"]
  space_types_mod = []
  space_types.each do |space_type|
    space_types_mod << (space_type["building_type"] + "_" + space_type["space_type"])
  end
  worksheet.write(row, col, space_types.size.to_f)
  row += 1
  total_match = 0
  space_types_mod.sort.each do |space_type_mod|
    worksheet.write(row, col, (space_type_mod + "_" + standard_version))
    space_type_map_info = space_type_maps.select{|space_type_map| (space_type_map[map_building_type].to_s + "_" + space_type_map[map_space_type].to_s) == space_type_mod.to_s}
    worksheet.write(row, (col+1), space_type_map_info.size.to_f)
    total_match += space_type_map_info.size.to_f
    row += 1
  end
  worksheet.write(row, (col+1), total_match)
  col += 2
end
in_file = "./data/space_type_upgrade_map.json"
space_type_maps = JSON.parse(File.read(in_file))["tables"]["space_type_upgrade_map"]["table"]
worksheet.write(0, col, space_type_maps.size.to_f)
workbook.close