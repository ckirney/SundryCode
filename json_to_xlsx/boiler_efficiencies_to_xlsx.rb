require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Fuel Type",
    "Minimum Capacity (BTU/hr)",
    "Maximum Capacity (BTU/hr)",
    "Maximum Thermal Efficiency"
]

json_titles = [
    "fuel_type",
    "minimum_capacity",
    "maximum_capacity",
    "minimum_thermal_efficiency"
]

in_file = './data/boilers.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["boilers"]["table"]
out_file = './' + in_file[7..-5] + 'xlsx'
workbook = WriteXLSX.new(out_file)
worksheet = workbook.add_worksheet
col = row = 0
col_titles.each do |col_title|
  worksheet.write(row, col, col_title)
  col += 1
end
row += 1
table_info.each do |table_entry|
  col = 0
  json_titles.each do |json_title|
    if table_entry[json_title] == '-'
      xlsx_output = 0
    else
      xlsx_output = table_entry[json_title]
    end
    worksheet.write(row, col, xlsx_output)
    col += 1
  end
  row += 1
end
workbook.close