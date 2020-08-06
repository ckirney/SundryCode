require 'fileutils'
require 'json'
require 'openstudio-standards'

cost_files = Dir['/home/osdev/res/**/qaqc.json']
cost_files.each do |cost_file|
  json_cont = JSON.parse(File.read(cost_file.to_s))
  template = (json_cont["measure_data_table"]).select { |info| info["measure_name"] == "btap_create_necb_prototype_building" && info["arg_name"] == "template" }
  fuel = json_cont['building']['principal_heating_source'].to_s.gsub(/\s+/, "")
  building_name = json_cont["building"]["name"].to_s.gsub(/\s+/, "")
  province = json_cont["geography"]["state_province_region"].to_s
  out_json_file = './results_files/' + building_name + '_' + template[0]["value"].to_s + '_' + fuel + '_' + province + '.json'
  loc = /run/ =~ cost_file
  in_osm_file = cost_file[0..(loc + 3)] + 'in.osm'
  out_osm_file = './results_files/' + building_name + '_' + template[0]["value"].to_s + '_' + fuel + '_' + province + '.osm'
  FileUtils.cp(cost_file, out_json_file)
  FileUtils.cp(in_osm_file, out_osm_file)
end