require 'fileutils'
require 'json'
require 'roo'

pre_vint_file = './previntage.json'
post_vint_file = './postvintage_1.json'
sample_pre_vint_out_file = './sample_prevint_out.json'
sample_post_vint_out_file = './sample_postvint_out.json'

pre_vint = JSON.parse(File.read(pre_vint_file))
post_vint = JSON.parse(File.read(post_vint_file))

pre_index_array = []
pre_vint_mod = []
post_vint_mod = []

=begin
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

diff_files = []

puts 'start check'
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
end

sample_pre = pre_vint_mod[395]
sample_post = post_vint_mod[694]
=end
sample_pre_vint_out = pre_vint[293]
sample_post_vint_out = post_vint[694]

File.write(sample_pre_vint_out_file, JSON.pretty_generate(sample_pre_vint_out))
File.write(sample_post_vint_out_file, JSON.pretty_generate(sample_pre_vint_out))
#puts 'hello'