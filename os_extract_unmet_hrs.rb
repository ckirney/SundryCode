require 'json'

class OS_extract_unmet_hrs
  # Name of file you want to add template fields to:
  in_json_file = "./simulations.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_unmet_hrs.json"
  output_array2 = []
  file = File.read(in_json_file)
  data_tables = JSON.parse(file)
  data_tables.each do |data_table|
    output_array = []
    if data_table["unmet_hours"]["cooling"] >= 300 || data_table["unmet_hours"]["cooling"] >= 300
      output_array = {
          building: data_table["building"],
          geography: data_table["geography"],
          unmet_hours: data_table["unmet_hours"]
      }
      output_array2 << output_array
    end
  end
  File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(output_array2))}
end