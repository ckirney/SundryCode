require 'json'

class OS_sim_extract
  # Name of file you want to add template fields to:
  in_json_file = "./simulations_20180628.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_outtest2.json"
  output_array = []
  tbl_index = 0
  output_array2 = []
  trackindex = 0
  build_test = Array.new(16, 0)
  weather_locs = ["nothing", "no_building", 100000]
#Z  output_array.push(weather_locs)
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
    output_array.each_with_index do |weather_loc, index|
      if weather_loc[0] == epw_file
        weather_locs = [epw_file, building_type, area_scale_factor]
        output_array[index].push(weather_locs)
        output_array[index][2] += 1
        flag = 1
      end
    end
    unless flag == 1
      weather_locs = [epw_file, "", 1]
      output_array.push(weather_locs)
      weather_locs = [epw_file, building_type, area_scale_factor]
      output_array[tbl_index].push(weather_locs)
      tbl_index += 1
    end
    case building_type
      when 'SecondarySchool'
        if build_test[0] == 0
          output_array2 << data_table
          build_test[0] = 1
        end
      when 'PrimarySchool'
        if build_test[1] == 0
          output_array2 << data_table
          build_test[1] = 1
        end
      when 'SmallOffice'
        if build_test[2] == 0
          output_array2 << data_table
          build_test[2] = 1
        end
      when 'MediumOffice'
        if build_test[3] == 0
          output_array2 << data_table
          build_test[3] = 1
        end
      when 'LargeOffice'
        if build_test[4] == 0
          output_array2 << data_table
          build_test[4] = 1
        end
      when 'SmallHotel'
        if build_test[5] == 0
          output_array2 << data_table
          build_test[5] = 1
        end
      when 'LargeHotel'
        if build_test[6] == 0
          output_array2 << data_table
          build_test[6] = 1
        end
      when 'Warehouse'
        if build_test[7] == 0
          output_array2 << data_table
          build_test[7] = 1
        end
      when 'RetailStandalone'
        if build_test[8] == 0
          output_array2 << data_table
          build_test[8] = 1
        end
      when 'RetailStripmall'
        if build_test[9] == 0
          output_array2 << data_table
          build_test[9] = 1
        end
      when 'QuickServiceRestaurant'
        if build_test[10] == 0
          output_array2 << data_table
          build_test[10] = 1
        end
      when 'FullServiceRestaurant'
        if build_test[11] == 0
          output_array2 << data_table
          build_test[11] = 1
        end
      when 'MidriseApartment'
        if build_test[12] == 0
          output_array2 << data_table
          build_test[12] = 1
        end
      when 'HighriseApartment'
        if build_test[13] == 0
          output_array2 << data_table
          build_test[13] = 1
        end
      when 'Hospital'
        if build_test[14] == 0
          output_array2 << data_table
          build_test[14] = 1
        end
      when 'Outpatient'
        if build_test[15] == 0
          output_array2 << data_table
          build_test[15] = 1
        end
    end

#    if trackindex <= 160
#      output_array2 << data_table
#      trackindex += 1
#    end
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

  File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(output_array2))}
end