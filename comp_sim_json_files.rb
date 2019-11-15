require 'json'
require 'fileutils'

in_sim_json_full = './simulations.json'
in_sim_json_int1 = './simulations_1.json'

sim_json_full = JSON.parse(File.read(in_sim_json_full))
sim_json_int1 = JSON.parse(File.read(in_sim_json_int1))

comp_file_res = []
sim_json_full.each_with_index do |sim_full_element, index|
  if sim_full_element == sim_json_int1[index]
    next
  else
    comp_file_res << index
  end
end

if comp_file_res.empty?
  puts "No mismatched results were found."
else
  puts "Mismatched results were found at the following indicies:"
  puts comp_file_res
end