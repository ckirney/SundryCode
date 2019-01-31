require 'json'

class GetZeroCostData
  # Following is the file name and location of the input file
  in_file = './simulations_2019-01-31.json'
  out_file = './output.json'
  file = File.read(in_file)
  data_tables = JSON.parse(file)
  out_info = []
  data_tables.each do |data_table|
    envelope_info = data_table['costing_information']['envelope']
    zero_cost = []
    envelope_info.each_with_index do |data, index|
      if index < envelope_info.size - 2
        test = data[1]['cost']
        if test == 0.0
          zero_cost << data
        end
      end
    end
    unless zero_cost.empty?
      out_info << {
          building_name: data_table['building']['name'],
          zero_cost: zero_cost
      }
    end
  end
  File.open(out_file,"w") {|each_file| each_file.write(JSON.pretty_generate(out_info))}
end