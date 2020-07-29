require 'fileutils'
require 'json'

cost_files = Dir['/home/osdev/cost_results/**/*.json']
cost_files.each do |cost_file|
  json_cont = JSON.parse(File.read(cost_file.to_s))
  template = (json_cont["measure_data_table"]).select { |info| info["measure_name"] == "btap_create_necb_prototype_building" && info["arg_name"] == "template" }
  fuel = json_cont['building']['principal_heating_source'].to_s.gsub(/\s+/, "")
  building_name = json_cont["building"]["name"].to_s.gsub(/\s+/, "")
  province = json_cont["geography"]["state_province_region"].to_s
  out_file = building_name + '_' + template[0]["value"].to_s + '_' + fuel + '_' + province + '.json'
  air_loop_info =
  json_cont["air_loops"].each do |air_loop|
    puts 'hello'
    loop_name = air_loop["name"]
    air_loop["heating_coils"].each do |heating_coil|
      heat_coil_name = heating_coil['name'] unless heating_coil['name'].nil?
      heat_coil_type = heating_coil['type'] unless heating_coil['type'].nil?
      unless heat_coil_name.nil? || heat_coil_type.nil?
        puts 'hello'

      end
    end
  end
end