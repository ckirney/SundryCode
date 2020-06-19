require 'write_xlsx'
require 'json'
require 'fileutils'

in_file = './data/schedules.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["schedules"]["table"]
#out_file = './' + in_file[7..-5] + 'xlsx'
out_file_pref = './' + in_file[7..-7]
#worksheet = workbook.add_worksheet
#worksheet.write(row, col, cell_info)
col = row = 0
table_info.each do |table_entry|
  table_let = table_entry["name"][5]
  if table_let == "*" || table_entry["name"] == "Activity"
    next
  end
  if table_entry["category"] == "Equipment" && table_entry["day_types"] == "Default|Wkdy"
    out_file = out_file_pref + "_" + table_let + '.xlsx'
    $workbook = WriteXLSX.new(out_file)
    $worksheet = $workbook.add_worksheet
    table_tit = "Operating Schedule " + table_let
    $worksheet.write(0,0, table_tit)
    $worksheet.write(1,0, "Day")
    $worksheet.write(1,1, "Time of Day")
    for i in 0..23
      $worksheet.write(2,i+1,i)
    end
    row = 3
  end
  if table_entry["day_types"] == "Default|Wkdy"
    sub_title = table_entry["category"] + ' - ' + table_entry["units"]
    $worksheet.write(row, 0, sub_title)
    row += 1
  end
  $worksheet.write(row, 0, table_entry["day_types"])
  for i in 0..23
    $worksheet.write(row, i+1, table_entry["values"][i])
  end
  row += 1
  if table_entry["category"] == "Thermostat Setpoint" && table_entry["day_types"] == "Sun|Hol"
    $workbook.close
  end
end