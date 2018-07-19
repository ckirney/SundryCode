require 'json'
require 'csv'

class OS_sim_extract2
  # Name of file you want to add template fields to:
  in_json_file = "./simulations_20180628.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_out_agwall.csv"
  output_array = []
  tbl_index = 0
  build_array = []
#  output_array.push(weather_locs)
  file = File.read(in_json_file)
  data_tables = JSON.parse(file)
  data_tables.each do |data_table|
    building_type = nil
    template_version = nil
    area_scale_factor = nil
    epw_file = nil
    outdoor_air = false
    data_table["measures"].each do |measure|
      if measure["name"] == "btap_create_necb_prototype_building_scale"
        building_type = measure["arguments"]["building_type"]
        area_scale_factor = measure["arguments"]["area_scale_factor"]
        epw_file = measure["arguments"]["epw_file"]
      end
    end
    flag = 0
    roofarea = data_table["envelope"]["outdoor_roofs_area_m2"]
    data_table["thermal_zones"].each do |thermal_zone|
      unless (/plenum/ =~ thermal_zone["name"].downcase).nil? and (/top/ =~ thermal_zone["name"].downcase).nil?
        roofarea = thermal_zone["floor_area"].to_f*thermal_zone["multiplier"].to_f
        flag = 1
      end
      unless (/attic/ =~ thermal_zone["name"].downcase).nil?
        roofarea = thermal_zone["floor_area"].to_f*thermal_zone["multiplier"].to_f
        flag = 1
      end
    end
    exterior_area = data_table["envelope"]["total_outdoor_area_m2"].to_f - data_table["envelope"]["outdoor_floors_area_m2"].to_f
    volume = data_table["building"]["volume"].to_f
#    flag = 1
    if flag == 1
      wall_area = 0
      volume = 0
      data_table["spaces"].each do |space|
        if ((/attic/ =~ space["name"].downcase).nil? && (/basement/ =~ space["name"].downcase).nil?) && ((/plenum/ =~ space["name"].downcase).nil? || (/top/ =~ space["name"].downcase).nil?)
#        if ((/attic/ =~ space["name"].downcase).nil?) && ((/plenum/ =~ space["name"].downcase).nil? || (/top/ =~ space["name"].downcase).nil?)
          wall_area += space["exterior_wall_area"].to_f*space["multiplier"].to_f
          volume += space["volume"].to_f*space["multiplier"].to_f
        end
      end
#      exterior_area = wall_area + roofarea - data_table["envelope"]["outdoor_floors_area_m2"].to_f + data_table["envelope"]["total_ground_area_m2"]
      exterior_area = wall_area + roofarea - data_table["envelope"]["outdoor_floors_area_m2"].to_f
    end
    flag = 0
    total_consumption = data_table["end_uses"]["heating_gj"].to_f + data_table["end_uses"]["cooling_gj"].to_f
    tedi = total_consumption/exterior_area
    output_array.each_with_index do |out_array, index|
      if out_array[0] == building_type && out_array[1] == area_scale_factor
        build_array = [data_table["geography"]["hdd"], tedi, area_scale_factor]
        output_array[index].push(build_array)
        flag = 1
      end
    end
    unless flag == 1
#      build_ = [epw_file, "", 1]
      output_array.push([building_type, area_scale_factor])
      build_array = [data_table["geography"]["hdd"], tedi, area_scale_factor]
      output_array[tbl_index].push(build_array)
      tbl_index += 1
    end

=begin
    data_table["measures"].each do |measure|
      if measure["name"] == "btap_create_necb_prototype_building_scale"
        building_type = measure["arguments"]["building_type"]
        template_version = measure["arguments"]["template"]
        area_scale_factor = measure["arguments"]["area_scale_factor"]
        epw_file = measure["arguments"]["epw_file"]
      elsif measure["display_name"] == "BTAPIdealAirLoadsOptionsEplus"
        outdoor_air = true
      end
    end
    extract_hash = {
        :conditioned_floor_area => data_table["building"]["conditioned_floor_area_m2"],
        :exterior_area => data_table["building"]["exterior_area_m2"],
        :volume => data_table["building"]["volume"],
        :hdd => data_table["geography"]["hdd"],
        :cdd => data_table["geography"]["cdd"],
        :heating_gj => data_table["end_uses"]["heating_gj"],
        :cooling_gj => data_table["end_uses"]["cooling_gj"],
        :ep_conditioned_floor_area_m2 => data_table["code_metrics"]["ep_conditioned_floor_area_m2"],
        :os_conditioned_floor_area_m2 => data_table["code_metrics"]["os_conditioned_floor_area_m2"],
        :building_tedi_gj_per_m2 => data_table["code_metrics"]["building_tedi_gj_per_m2"],
        :building_medi_gj_per_m2 => data_table["code_metrics"]["building_medi_gj_per_m2"],
        :building_type => building_type,
        :template_version => template_version,
        :epw_file => epw_file,
        :area_scale_factor => area_scale_factor,
        :outdoor_air => outdoor_air
    }
=end
#    output_array << extract_hash
  end
=begin
  output_array.each_with_index do |outp, outindex|
    puts outp[0..1]
#      puts outp[1]
    arraylen = outp.length
    outp[2..arraylen].each do |subarray|
      puts "test1"
      puts subarray
    end
    puts "test"
  end
=end
  CSV.open(out_json_file, "w") do |csv|
    output_array.each_with_index do |out, outindex|
      csv << [out[0], out[1]]
      arraylen = out.length
      out[2..arraylen].each do |out_num|
        csv << [out_num[0], out_num[1]]
      end
    end
  end
#  File.open(out_json_file,"w") {|each_file| each_file.write(output_array)}
end