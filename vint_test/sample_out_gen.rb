require 'fileutils'
require 'json'
require 'csv'

# Put json output into array of hashes
post_vint_file = './simulations_revised_BTAP_vintage_analysis_2020-03-16.json'
sample_out_file = './new_samp_out_2015.json'
post_vint = JSON.parse(File.read(post_vint_file))
out_info = post_vint.select{|out_rec| out_rec["template"] == "NECB2015" && out_rec["building_type"] == "Hospital" && out_rec["building"]["principal_heating_source"] == "Natural Gas"}[3]

File.write(sample_out_file, JSON.pretty_generate(out_info))