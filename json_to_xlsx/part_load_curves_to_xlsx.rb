require 'write_xlsx'
require 'json'
require 'fileutils'

col_titles = [
    "Curve Name",
    "HVAC Category",
    "Curve Type",
    "Dependent Variable Name",
    "Independent Variable 1 Name",
    "Independent Variable 2 Name",
    "Coefficient 1",
    "Coefficient 2",
    "Coefficient 3",
    "Coefficient 4",
    "Coefficient 5",
    "Coefficient 6",
    "Minimum Allowable Value of Independent Variable 1",
    "Maximum Allowable Value of Independent Variable 1",
    "Minimum Allowable Value of Independent Variable 2",
    "Maximum Allowable Value of Independent Variable 2",
]

json_titles = [
    "name",
    "category",
    "form",
    "dependent_variable",
    "independent_variable_1",
    "independent_variable_2",
    "coeff_1",
    "coeff_2",
    "coeff_3",
    "coeff_4",
    "coeff_5",
    "coeff_6",
    "minimum_independent_variable_1",
    "maximum_independent_variable_1",
    "minimum_independent_variable_2",
    "maximum_independent_variable_2",
]

in_file = './data/curves.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["curves"]["table"]
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