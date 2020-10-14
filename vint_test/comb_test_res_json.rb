require 'fileutils'
require 'json'

failed_runs = []
qaqc_res = []
curdir = File.dirname(__FILE__)
cost_fold = "/home/osdev/btap_costing/costing_output/"
dirlist = Dir.entries(cost_fold).select {|entry| File.directory? File.join(cost_fold, entry) and !(entry == '.' || entry == '..')}
dirlist.each do |file_dir|
  split_name = file_dir.split('-')
  qaqc_loc = cost_fold + file_dir + '/run/001_btap_results/qaqc.json'
  osm_loc = cost_fold + file_dir + '/in.osm'
  if File.exist?(qaqc_loc)
    qaqc_orig = JSON.parse(File.read(qaqc_loc))
    qaqc_orig["building_type"] = split_name[0]
    qaqc_orig["template"] = split_name[1]
    qaqc_orig["primary_heating_fuel"] = split_name[2]
    qaqc_orig["weather_location"] = split_name[3]
    qaqc_res << qaqc_orig
    osm_out = curdir + "/" + file_dir + '.osm'
    FileUtils.cp osm_loc, osm_out
  else
    failed_runs << qaqc_loc
  end
end

fail_loc = curdir + "/failed_files.json"
qaqc_out_loc = curdir + "/test_res_2020-10-15.json"
File.write(fail_loc, JSON.pretty_generate(failed_runs)) unless failed_runs.empty?
File.write(qaqc_out_loc, JSON.pretty_generate(qaqc_res))