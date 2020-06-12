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

in_file = './space_types_1980TO2010.json'
json_info = JSON.parse(File.read(in_file))
space_types = json_info["tables"]["space_types"]["table"]

workbook = WriteXLSX.new('space_types.xlsx')
worksheet = workbook.add_worksheet
col = row = 0
col_titles.each do |col_title|
  worksheet.write(row, col, col_title)
  col += 1
end
row += 1
space_types.each do |space_type|
  col = 0
  json_titles.each do |json_title|
    worksheet.write(row, col, space_type[json_title])
    col += 1
  end
  row += 1
end
workbook.close