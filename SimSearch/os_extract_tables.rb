require 'json'

class OS_table_extract
  # Name of file you want to add template fields to:
  in_json_file = "./simulations.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_out.json"
  output_array2 = []
  count = 0
  file = File.read(in_json_file)
  data_tables = JSON.parse(file)
  data_tables.each do |data_table|
    count += 1
    if count < 10
      output_array2 << data_table
    end
  end
  File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(output_array2))}
end