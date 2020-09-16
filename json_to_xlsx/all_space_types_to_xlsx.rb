require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Building Type",
    "Space Type",
    "NECB Occupancy",
    "Outdoor Air Flow Rate",
    "Lighting",
    "Space Equipment Electrical Load",
    "Service Hot Water Flow Rate",
    "NECB Schedule Table"
]

col_units = [
    "",
    "",
    "people/1000 ft2",
    "cfm/ft2",
    "W/ft2",
    "W/ft2",
    "US Gal/hr/ft2",
    ""
]

json_titles = [
    "building_type",
    "space_type",
    "occupancy_per_area",
    "ventilation_per_area",
    "lighting_per_area",
    "electric_equipment_per_area",
    "service_water_heating_peak_flow_per_area",
    "necb_schedule_type"
]

standard_versions = [
    "BTAPPRE1980",
    "NECB2011",
    "NECB2015",
    "NECB2017"
]

workbook = WriteXLSX.new('all_space_types.xlsx')

standard_versions.each do |standard_version|
  worksheet = workbook.add_worksheet(standard_version)
  row = col = 0
  in_file = "./data/space_types_" + standard_version + ".json"
  space_types = JSON.parse(File.read(in_file))["tables"]["space_types"]["table"]
  col_titles.each do |col_title|
    worksheet.write(row, col, col_title)
    col += 1
  end
  row += 1
  col = 0
  col_units.each do |col_unit|
    worksheet.write(row, col, col_unit)
    col += 1
  end
  space_types.each do |space_type|
    row += 1
    col = 0
    json_titles.each do |json_title|
      worksheet.write(row, col, space_type[json_title])
      col += 1
    end
  end
end

workbook.close