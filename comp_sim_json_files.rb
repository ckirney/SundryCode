require 'json'
require 'fileutils'

in_sim_json_full = './simulations.json'
#in_sim_json_int1 = './simulations_1.json'

sim_json_full = JSON.parse(File.read(in_sim_json_full))
#sim_json_int1 = JSON.parse(File.read(in_sim_json_int1))
index = 0
out_data = []
sim_json_full.each do |sim|
  code_ver = sim['measure_data_table'].select{|data|
    data['measure_name'].to_s.upcase == "btap_standard_loads".upcase
  }
  srr_fdwr_set = sim['measure_data_table'].select{|data|
    data['measure_name'].to_s.upcase == "btap_measure_geometry".upcase
  }
  srr_fdwr_set_out = []
  srr_fdwr_set.each do |srr_fdwr|
    srr_fdwr_set_out << {
        fdwr_srr: srr_fdwr['arg_name'],
        value: srr_fdwr['value']
    }
  end
  out_code_ver = code_ver[0]['value']
  window_info_out = []
  skylight_info_out = []
  window_info = sim['costing_information']['envelope']['construction_costs']
  window_info.each do |wind_info|
    unless /Window/.match(wind_info['name']).nil?
      window_info_out << wind_info['conductance']
    end
    unless /Skylight/.match(wind_info['name']).nil?
      skylight_info_out << wind_info['conductance']
    end
  end
  out_data << {
      building_type:  sim['building']['name'],
      code:  out_code_ver,
      fdwr_srr_set: srr_fdwr_set_out,
      fdwr: sim['envelope']['fdwr'],
      srr: sim['envelope']['srr'],
      window_info: window_info_out,
      skylight_info:  skylight_info_out
  }
  #out_name = "./sim_" + index.to_s + ".json"
  #File.open(out_name, 'w') {|out| out.write(JSON.pretty_generate(sim))}
  #index += 1
end
#comp_file_res = []
#sim_json_full.each_with_index do |sim_full_element, index|
#  if sim_full_element == sim_json_int1[index]
#    next
#  else
#    comp_file_res << index
#  end
#end

#if comp_file_res.empty?
#  puts "No mismatched results were found."
#else
#  puts "Mismatched results were found at the following indicies:"
#  puts comp_file_res
#end
puts 'hello'