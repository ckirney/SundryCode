require 'fileutils'
require 'json'
require 'roo'

def diff(one, other)
  (one.keys + other.keys).uniq.inject({}) do |memo, key|
    unless one.key?(key) && other.key?(key) && one[key] == other[key]
      memo[key] = [one.key?(key) ? one[key] : :_no_key, other.key?(key) ? other[key] : :_no_key]
    end
    memo
  end
end

post_vint_file = './simulations_2020-02-24.json'
#sample_pre_vint_out_file = './sample_prevint_out.json'
#sample_post_vint_out_file = './sample_postvint_out1.json'

post_vint = JSON.parse(File.read(post_vint_file))

post_index_array = []
post_vint_mod = []

post_vint.sort_by!{ |vint_rec| vint_rec["building"]["principal_heating_source"]}
sort_vint = []
post_vint.each do |vint_rec|

  puts 'hello'
    #sort_vint[]
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

post_vint_mod.each do |vint_rec|
  next unless post_index_array.select {|ind_sel| ind_sel == vint_rec[:index]}.empty?
  other_post_vint = post_vint_mod.select {|vint_sel|
    (vint_sel[:building_type] == vint_rec[:building_type]) && (vint_sel[:city] == vint_rec[:city]) && (vint_sel[:heat_fuel] == vint_rec[:heat_fuel])
  }
  other_post_vint.sort_by! { |post_vint_hash| post_vint_hash[:template]}

  other_post_vint.each do |pre_vint_rec|
    post_index_array << pre_vint_rec[:index]
  end
end
out_diff = "./post_vint_diff.json"
puts 'hello'

#File.write(sample_pre_vint_out_file, JSON.pretty_generate(sample_pre_vint_out))
#File.write(sample_post_vint_out_file, JSON.pretty_generate(sample_post_vint_out))
File.write(out_diff, JSON.pretty_generate(diff_info))
#puts 'hello'