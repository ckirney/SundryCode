require 'fileutils'
require 'json'
require 'csv'

# Put json output into array of hashes
res_files = [
    './simulations_revised_BTAP_vintage_analysis_2020-03-16.json',
    './simulations_nrcan_occ_2020-03-11.json',
    './simulations_ashrae_occ_2020-03-11.json'
]

out_json_name = "./occ_test_results.json"

occ_info = [
    'a_orig_occ',
    'b_nrcan_occ',
    'c_ashrae_occ'
]

all_res = []

res_files.each_with_index do |res_file, index|
  ind_analysis = nil
  ind_analysis = JSON.parse(File.read(res_file))
  ind_analysis.each do |ind_datapoint|
    if (ind_datapoint["template"].to_s.include?("BTAPPRE1980") || ind_datapoint["template"].to_s.include?("BTAP1980TO2010") || ind_datapoint["building_type"].to_s.include?("Hospital") || ind_datapoint["building_type"].to_s.include?("Outpatient"))
      #if ind_datapoint["template"].to_s.include?("NECB2011")
      #unless ind_datapoint["building_type"].to_s.include?("Hospital") || ind_datapoint["building_type"].to_s.include?("Outpatient")
      #  ind_datapoint["new_template"] = ind_datapoint["template"] + "_" + occ_info[index]
      #  all_res << ind_datapoint
      #end
      next
    else
      #next
      ind_datapoint["new_template"] = ind_datapoint["template"] + "_" + occ_info[index]
      all_res << ind_datapoint
    end
  end
end

File.write(out_json_name, JSON.pretty_generate(all_res))