require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Building Applicability",
    "Equipment Type",
    "Fan Type",
    "Minimum Performance (gpm/hp)"
]

json_titles = [
    "template",
    "equipment_type",
    "fan_type",
    "minimum_performance"
]

in_file = './data/heat_rejection.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["heat_rejection"]["table"]
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
    xlsx_output = table_entry[json_title]
    if xlsx_output == '-'
      xlsx_output = 0
    else
      xlsx_output.is_a?(Float) ? xlsx_output.to_f : xlsx_output.to_s
    end
    worksheet.write(row, col, xlsx_output)
    col += 1
  end
  row += 1
end
workbook.close