require 'write_xlsx'
require 'json'
require 'fileutils'

standard_versions = [
    "BTAPPRE1980",
    "NECB2011",
    "NECB2015",
    "NECB2017"
]

workbook = WriteXLSX.new('space_types_list.xlsx')
worksheet = workbook.add_worksheet

col = 0
standard_versions.each do |standard_version|
  col += 1
  row = 0
  in_file = "./data/space_types_" + standard_version + ".json"
  space_types = JSON.parse(File.read(in_file))["tables"]["space_types"]["table"]
  space_types_mod = []
  space_types.each do |space_type|
    space_types_mod << (space_type["building_type"] + "_" + space_type["space_type"] + "_" + standard_version)
  end
  worksheet.write(row, col, space_types.size.to_f)
  row += 1
  space_types_mod.sort.each do |space_type_mod|
    worksheet.write(row, col, space_type_mod)
    row += 1
  end
end
in_file = "./data/space_type_upgrade_map.json"
space_type_maps = JSON.parse(File.read(in_file))["tables"]["space_type_upgrade_map"]["table"]
worksheet.write(0, (col + 1), space_type_maps.size.to_f)
workbook.close