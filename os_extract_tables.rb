require 'json'

class OS_table_extract
  # Name of file you want to add template fields to:
  in_json_file = "./simulations.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_out.json"
  output_array = []
  tbl_index = 0
  output_array2 = []
  trackindex = 0
  build_test = Array.new(16, 0)
  weather_locs = ["nothing", "no_building", 100000]
#Z  output_array.push(weather_locs)
  file = File.read(in_json_file)
  data_tables = JSON.parse(file)
  data_tables.each do |data_table|
    count += 1
    if count < 100
      output_array2 << data_table
    end
  end
  File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(output_array2))}
end