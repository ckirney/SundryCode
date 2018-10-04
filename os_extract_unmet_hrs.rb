require 'json'

class OS_extract_unmet_hrs
  # Name of file you want to add template fields to:
  in_json_file = "./simulations.json"
  # Name of file you want this script to produce:
  out_json_file = in_json_file[0, (in_json_file.length - 5)] + "_unmet_hrs.json"
  output_array2 = []
  file = File.read(in_json_file)
  data_tables = JSON.parse(file)
  archetype_unmet_hrs = {
      SecondarySchool: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      PrimarySchool: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      SmallOffice: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      MediumOffice: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      LargeOffice: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      SmallHotel: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      LargeHotel: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      Warehouse: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      RetailStandalone: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      RetailStripmall: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      QuickServiceRestaurant: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      FullServiceRestaurant: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      MidriseApartment: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      HighriseApartment: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      Hospital: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}},
      Outpatient: {heating: {number: 0, max: 0, min: 10000, average: 0}, cooling: {number: 0, max: 0, min: 100000, average: 0}}
  }
  data_tables.each do |data_table|
    output_array = []
    building_type = ""
    if data_table["unmet_hours"]["cooling"] >= 300 || data_table["unmet_hours"]["cooling"] >= 300
      data_table["measures"].each do |measure|
        if measure["name"] == "btap_create_necb_prototype_building"
          building_type = measure["arguments"]["building_type"]
        end
      end
      case building_type
      when 'SecondarySchool'
        if data_table["unmet_hours"]["cooling"] >= 300
          archetype_unmet_hrs[:SecondarySchool][:cooling][:number] = archetype_unmet_hrs[:SecondarySchool][:cooling][:number].to_i + 1
          if archetype_unmet_hrs[:SecondarySchool][:cooling][:max].to_f < data_table["unmet_hours"]["cooling"].to_f
            archetype_unmet_hrs[:SecondarySchool][:cooling][:max] = data_table["unmet_hours"]["cooling"].to_f
          end
          if archetype_unmet_hrs[:SecondarySchool][:cooling][:min].to_f > data_table["unmet_hours"]["cooling"].to_f
            archetype_unmet_hrs[:SecondarySchool][:cooling][:min] = data_table["unmet_hours"]["cooling"].to_f
          end
          archetype_unmet_hrs[:SecondarySchool][:cooling][:average] = archetype_unmet_hrs[:SecondarySchool][:cooling][:average].to_f + data_table["unmet_hours"]["cooling"].to_f
        end
        if data_table["unmet_hours"]["heating"] >= 300
          archetype_unmet_hrs[:SecondarySchool][:heating][:number] = archetype_unmet_hrs[:SecondarySchool][:heating][:number].to_i + 1
          if archetype_unmet_hrs[:SecondarySchool][:heating][:max].to_f < data_table["unmet_hours"]["heating"].to_f
            archetype_unmet_hrs[:SecondarySchool][:heating][:max] = data_table["unmet_hours"]["heating"].to_f
          end
          if archetype_unmet_hrs[:SecondarySchool][:heating][:min].to_f > data_table["unmet_hours"]["heating"].to_f
            archetype_unmet_hrs[:SecondarySchool][:heating][:min] = data_table["unmet_hours"]["heating"].to_f
          end
          archetype_unmet_hrs[:SecondarySchool][:heating][:average] = archetype_unmet_hrs[:SecondarySchool][:heating][:average].to_f + data_table["unmet_hours"]["heating"].to_f
        end
      when 'PrimarySchool'
        if data_table["unmet_hours"]["cooling"] >= 300
          archetype_unmet_hrs[:PrimarySchool][:cooling][:number] = archetype_unmet_hrs[:PrimarySchool][:cooling][:number].to_i + 1
          if archetype_unmet_hrs[:PrimarySchool][:cooling][:max].to_f < data_table["unmet_hours"]["cooling"].to_f
            archetype_unmet_hrs[:PrimarySchool][:cooling][:max] = data_table["unmet_hours"]["cooling"].to_f
          end
          if archetype_unmet_hrs[:PrimarySchool][:cooling][:min].to_f > data_table["unmet_hours"]["cooling"].to_f
            archetype_unmet_hrs[:PrimarySchool][:cooling][:min] = data_table["unmet_hours"]["cooling"].to_f
          end
          archetype_unmet_hrs[:PrimarySchool][:cooling][:average] = archetype_unmet_hrs[:PrimarySchool][:cooling][:average].to_f + data_table["unmet_hours"]["cooling"].to_f
        end
        if data_table["unmet_hours"]["heating"] >= 300
          archetype_unmet_hrs[:PrimarySchool][:heating][:number] = archetype_unmet_hrs[:PrimarySchool][:heating][:number].to_i + 1
          if archetype_unmet_hrs[:PrimarySchool][:heating][:max].to_f < data_table["unmet_hours"]["heating"].to_f
            archetype_unmet_hrs[:PrimarySchool][:heating][:max] = data_table["unmet_hours"]["heating"].to_f
          end
          if archetype_unmet_hrs[:PrimarySchool][:heating][:min].to_f > data_table["unmet_hours"]["heating"].to_f
            archetype_unmet_hrs[:PrimarySchool][:heating][:min] = data_table["unmet_hours"]["heating"].to_f
          end
          archetype_unmet_hrs[:PrimarySchool][:heating][:average] = archetype_unmet_hrs[:PrimarySchool][:heating][:average].to_f + data_table["unmet_hours"]["heating"].to_f
        end
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
      output_array = {
          building: data_table["building"],
          geography: data_table["geography"],
          unmet_hours: data_table["unmet_hours"]
      }
      output_array2 << output_array
    end
  end
  File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(output_array2))}
end