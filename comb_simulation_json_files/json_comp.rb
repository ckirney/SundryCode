require 'fileutils'
require 'json'

sim_in_temp = './281/simulations_'
miss_in_temp = './281/missing_files_'
out_sim_file = './281/simulations.json'
out_miss_file = './281/missing_files.json'

sim_out = []
miss_out = []
miss_size = 0

#test_sim = JSON.parse(File.read(out_sim_file))
#test_miss = JSON.parse(File.read(out_miss_file))
#sim_size = test_sim.size
#miss_size = test_miss.size
#puts 'hello'

for i in 1..18
  in_sim_file = sim_in_temp + i.to_s + '.json'
  in_miss_file = miss_in_temp + i.to_s + '.json'
  in_sim = JSON.parse(File.read(in_sim_file))
  in_miss = JSON.parse(File.read(in_miss_file))
  in_sim.each do |ind_res|
    sim_out << ind_res
  end
  in_miss.each do |ind_miss|
    miss_out << ind_miss
    miss_size += 1
  end
end

puts miss_size
File.write(out_sim_file, sim_out.to_json)
File.write(out_miss_file, JSON.pretty_generate(miss_out))