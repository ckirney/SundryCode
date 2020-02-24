require 'fileutils'
require 'json'
require 'roo'
require 'hashdiff'

pre_vint_file = './postvintage_1.json'
post_vint_file = './postvintage_2.json'
#sample_pre_vint_out_file = './sample_prevint_out.json'
#sample_post_vint_out_file = './sample_postvint_out1.json'

pre_vint = JSON.parse(File.read(pre_vint_file))
post_vint = JSON.parse(File.read(post_vint_file))

pre_index_array = []
pre_vint_mod = []
post_vint_mod = []


pre_vint.each_with_index do |vint_rec, index|
  pre_vint_mod << {
      index: index,
      building_type: vint_rec["building_type"],
      template: vint_rec["template"],
      city: vint_rec["geography"]["city"],
      heat_fuel: vint_rec["measure_data_table"].select {|measure_rec| measure_rec["arg_name"] == "primary_heating_fuel"}[0]["value"],
      rec: vint_rec
  }
end

post_vint.each_with_index do |vint_rec, index|
  post_vint_mod << {
      index: index,
      building_type: vint_rec["building_type"],
      template: vint_rec["template"],
      city: vint_rec["geography"]["city"],
      heat_fuel: vint_rec["measure_data_table"].select {|measure_rec| measure_rec["arg_name"] == "primary_heating_fuel"}[0]["value"],
      rec: vint_rec
  }
end

diff_info = []

puts 'start check'
diff_index = 0
pre_vint_mod.each do |vint_rec|
  next unless pre_index_array.select {|ind_sel| ind_sel == vint_rec[:index]}.empty?
  other_pre_vint = pre_vint_mod.select {|vint_sel|
    (vint_sel[:building_type] == vint_rec[:building_type]) && (vint_sel[:city] == vint_rec[:city]) && (vint_sel[:heat_fuel] == vint_rec[:heat_fuel])
  }
  other_pre_vint.sort_by! { |pre_vint_hash| pre_vint_hash[:template]}

  other_pre_vint.each do |pre_vint_rec|
    pre_index_array << pre_vint_rec[:index]
  end
  sim_post_vint = post_vint_mod.select {|vint_sel|
    (vint_sel[:building_type] == vint_rec[:building_type]) && (vint_sel[:city] == vint_rec[:city]) && (vint_sel[:heat_fuel] == vint_rec[:heat_fuel])
  }
  sim_post_vint.sort_by! { |post_vint_hash| post_vint_hash[:template]}
  other_pre_vint.each_with_index do |pre_vint, index|
    unless pre_vint[:rec]["sql_data"].to_a == sim_post_vint[index][:rec]["sql_data"].to_a
      diff_info << {
          index_pre: pre_vint[:index],
          index_post: sim_post_vint[index][:index],
          building_type: pre_vint[:building_type],
          template: pre_vint[:template],
          city: pre_vint[:city],
          heat_fuel: pre_vint[:heat_fuel],
          diff: pre_vint[:rec]["sql_data"].to_a - sim_post_vint[index][:rec]["sql_data"].to_a,
          pre_sql: pre_vint[:rec]["sql_data"],
          post_sql: sim_post_vint[index][:rec]["sql_data"]
      }
      pre_out_diff_name = "./pre_out_sql_" + diff_index.to_s + ".json"
      File.write(pre_out_diff_name, JSON.pretty_generate(pre_vint[:rec]["sql_data"]))
      post_out_diff_name = "./post_out_sql_" + diff_index.to_s + ".json"
      File.write(post_out_diff_name, JSON.pretty_generate(sim_post_vint[index][:rec]["sql_data"]))
      diff_index += 1
    end
  end
end
out_diff = "./post_vint_diff.json"
puts 'hello'
#sample_pre = pre_vint_mod[395]
#sample_post = post_vint_mod[694]

#sample_pre_vint_out = pre_vint[293]
#sample_post_vint_out = post_vint[694]

#File.write(sample_pre_vint_out_file, JSON.pretty_generate(sample_pre_vint_out))
#File.write(sample_post_vint_out_file, JSON.pretty_generate(sample_post_vint_out))
File.write(out_diff, JSON.pretty_generate(diff_info))
#puts 'hello'