require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Heater Type",
    "Type of Unitary AC",
    "Minimum Capacity (BTU/hr)",
    "Maximum Capacity (BTU/hr)",
    "Energy Efficiency Ratio"
]

json_titles = [
    "heating_type",
    "subcategory",
    "minimum_capacity",
    "maximum_capacity",
    "minimum_energy_efficiency_ratio"
]

in_file = './data/unitary_acs.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["unitary_acs"]["table"]
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
    elsif xlsx_output.nil?
      if json_title.include?('coeff')
        xlsx_output = 0
      else
        xlsx_output = '-'
      end
    else
      xlsx_output.is_a?(Float) ? xlsx_output.to_f : xlsx_output.to_s
    end
    worksheet.write(row, col, xlsx_output)
    col += 1
  end
  row += 1
end
workbook.close