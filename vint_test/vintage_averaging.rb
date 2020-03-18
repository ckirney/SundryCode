require 'fileutils'
require 'json'
require 'csv'

# Put json output into array of hashes
post_vint_file = './simulations_revised_BTAP_vintage_analysis_2020-03-16.json'
#res_csv_name = "./post_2_results.csv"
res_csv_name = post_vint_file[0..-5] + "csv"
res_avg_csv_name = post_vint_file[0..-6] + "_avg.csv"
post_vint = JSON.parse(File.read(post_vint_file))

#Get unique templates, weather cities, heating types, and building types from json
pre_present = false
templates = []
code_ver_pre = post_vint.uniq{|ind_res| ind_res["template"]}
code_ver_pre.each {|code_ver_ind| templates << code_ver_ind["template"]}
templates.sort!
# Switch the locations of BTAPPRE1980 and BTAP1980TO2010 buildings for easier comparison later
if (templates.include?("BTAPPRE1980") && templates.include?("BTAP1980TO2010"))
  pre_index = templates.index("BTAPPRE1980")
  post_index = templates.index("BTAP1980TO2010")
  templates[pre_index] = "BTAP1980TO2010"
  templates[post_index] = "BTAPPRE1980"
  pre_present = true
end

weather_cities = []
weather_city_pre = post_vint.uniq{|ind_res| ind_res["geography"]["city"]}
weather_city_pre.each {|weather_ind| weather_cities << weather_ind["geography"]["city"]}

fuel_types = []
fuel_type_pre = post_vint.uniq{|ind_res| ind_res["building"]["principal_heating_source"]}
fuel_type_pre.each {|fuel_ind| fuel_types << fuel_ind["building"]["principal_heating_source"]}

building_types = []
building_type_pre = post_vint.uniq{|ind_res| ind_res["building_type"]}
building_type_pre.each {|building_ind| building_types << building_ind["building_type"]}

# Sort json output by building type, then weather city, then fuel type, and finally vintage
sort_vint = []
building_types.sort.each do |building_type|
  sort_building_type = post_vint.select{|ind_rec| ind_rec["building_type"] == building_type}
  weather_cities.sort.each do |weather_city|
    sort_weather_loc = sort_building_type.select{|ind_rec| ind_rec["geography"]["city"] == weather_city}
    fuel_types.sort.each do |fuel_type|
      sort_fuel_types = sort_weather_loc.select{|ind_rec| ind_rec["building"]["principal_heating_source"] == fuel_type}
      templates.each do |template|
        sort_vint << sort_fuel_types.select{|ind_rec| ind_rec["template"] == template}[0]
      end
    end
  end
end

res_array = []
# Put building type, weather city, heating fuel type, template, sql data, analysis name, analysis id, and data point id
# into a csv file
CSV.open(res_csv_name, "w") do |csv|
  csv << [
      "Building_Type",                                        #0
      "Weather_City",                                         #1
      "Fuel_Type",                                            #2
      "Template",                                             #3
      "Heating_Gas_GJ",                                       #4
      "Heating_Elec_GJ",                                      #5
      "Total_Heating_GJ",                                     #6
      "Cooling_Elec_GJ",                                      #7
      "Interior_Lighting_Elec_GJ",                            #8
      "Interior_Equipment_Elec_GJ",                           #9
      "Fans_Elec_GJ",                                         #10
      "Pumps_Elec_GJ",                                        #11
      "Heat_Rejection_GJ",                                    #12
      "Heat_Recovery_GJ",                                     #13
      "Water_Systems_Gas_GJ",                                 #14
      "Water_Systems_Elec_GJ",                                #15
      "Water_Systems_Tot_GJ",                                 #16
      "Water_Systems_m3",                                     #17
      "Total_End_Uses_Elec_GJ",                               #18
      "Total_End_Uses_Gas_GJ",                                #19
      "Total_End_Uses_Water_m3",                              #20
      "Total_Site_Energy_GJ",                                 #21
      "Site_Energy_Per_Total_Building_Area_MJ/m2",            #22
      "Site_Energy_Per_Conditioned_Building_Area_MJ/m2",      #23
      "Total_Source_Energy_GJ",                               #24
      "Source_Energy_Per_Total_Building_Area_MJ/m2",          #25
      "Source_Energy_Per_Conditioned_Building_Area_MJ/m2",    #26
      "Analysis_Name",                                        #27
      "Analysis_ID",                                          #28
      "Data_Point_ID",                                        #29
      "Gas_Diff_GJ",                                          #30
      "Electric_Diff_GJ"                                      #31
  ]
  sort_vint.each_with_index do |vint_rec, index|
    csv_out = [
        vint_rec["building_type"],
        vint_rec["geography"]["city"],
        vint_rec["building"]["principal_heating_source"],
        vint_rec["template"]
    ]
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heating"}[0]["natural_gas_GJ"].nil? ? heat_gas = 0 : heat_gas = vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heating"}[0]["natural_gas_GJ"] #heating
    csv_out << heat_gas
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heating"}[0]["electricity_GJ"].nil? ? heat_elec = 0 : heat_elec = vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heating"}[0]["electricity_GJ"] #heating
    csv_out << heat_elec
    csv_out << (heat_gas + heat_elec)
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Cooling"}[0]["electricity_GJ"].nil? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Cooling"}[0]["electricity_GJ"] #cooling
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Interior Lighting"}[0]["electricity_GJ"].nil? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Interior Lighting"}[0]["electricity_GJ"] #lighting
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Interior Equipment"}[0]["electricity_GJ"].nil? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Interior Equipment"}[0]["electricity_GJ"] #equip
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Fans"}[0]["electricity_GJ"].nil? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Fans"}[0]["electricity_GJ"] #fans
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Pumps"}.empty? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Pumps"}[0]["electricity_GJ"] #pumps
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heat Rejection"}.empty? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heat Rejection"}[0]["electricity_GJ"] #heat rejection
    vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heat Recovery"}.empty? ? csv_out << 0 : csv_out << vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Heat Recovery"}[0]["electricity_GJ"] #heat recovery
    water_systems = vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Water Systems"}[0] #water systems
    water_systems["natural_gas_GJ"].nil? ? water_gas = 0 : water_gas = water_systems["natural_gas_GJ"] #gas water systems
    csv_out << water_gas
    water_systems["electricity_GJ"].nil? ? water_elec = 0 : water_elec = water_systems["electricity_GJ"] #electricity water systems
    csv_out << water_elec
    csv_out << (water_gas + water_elec)
    csv_out << water_systems["water_m3"]
    tot_end_uses = vint_rec["sql_data"][0]["table"].select{|data| data["name"] == "Total End Uses"}[0] #total end uses
    tot_end_uses["natural_gas_GJ"].nil? ? csv_out << 0 : csv_out << tot_end_uses["natural_gas_GJ"] #total end uses gas
    tot_end_uses["electricity_GJ"].nil? ? csv_out << 0 : csv_out << tot_end_uses["electricity_GJ"] #total end uses electricity
    csv_out << tot_end_uses["water_m3"] #total end uses water
    total_site = vint_rec["sql_data"][1]["table"].select{|data| data["name"] == "Total Site Energy"}[0] #Site Energy
    csv_out << total_site["total_energy_GJ"] #Site Energy
    csv_out << total_site["energy_per_total_building_area_MJ/m2"] #Site Energy
    csv_out << total_site["energy_per_conditioned_building_area_MJ/m2"] #Site Energy
    total_source = vint_rec["sql_data"][1]["table"].select{|data| data["name"] == "Total Source Energy"}[0] #Source Energy
    csv_out << total_source["total_energy_GJ"] #Source Energy
    csv_out << total_source["energy_per_total_building_area_MJ/m2"] #Source Energy
    csv_out << total_source["energy_per_conditioned_building_area_MJ/m2"] #Source Energy
    csv_out << vint_rec["analysis_name"]
    csv_out << vint_rec["analysis_id"]
    csv_out << vint_rec["run_uuid"]
    # Include to highlight when NECB2011 uses more energy than BTAP1980TO2010
    if (pre_present && ((vint_rec["template"] == "BTAP1980TO2010") || (vint_rec["template"] == "NECB2011")))
      sort_vint[index-1]["sql_data"][0]["table"][0]["natural_gas_GJ"].nil? ? old_heat_gas = 0: old_heat_gas = sort_vint[index-1]["sql_data"][0]["table"][0]["natural_gas_GJ"]
      sort_vint[index-1]["sql_data"][0]["table"][0]["electricity_GJ"].nil? ? old_heat_elec = 0: old_heat_elec = sort_vint[index-1]["sql_data"][0]["table"][0]["electricity_GJ"]
      gas_heat_diff = old_heat_gas - heat_gas
      csv_out << gas_heat_diff
      elec_heat_diff = old_heat_elec - heat_elec
      csv_out << elec_heat_diff
      if vint_rec["template"] == "NECB2011"
        if (gas_heat_diff < 0 || elec_heat_diff < 0)
          csv_out << vint_rec["building_type"]
        end
      end
    end
    csv << csv_out
    res_array << csv_out
  end
end

# Average by building type, fuel type, and template across weather locations
building_avg = []
templates.each do |template|
  fuel_types.each do |fuel_type|
    building_types.each do |building_type|
      col_res = res_array.select {|ind_res| ind_res[0] == building_type && ind_res[2] == fuel_type && ind_res[3] == template}
      array_size = col_res.size
      building_type_avg = [
          building_type,
          "all_weather_locations",
          fuel_type,
          template
      ]
      for i in 4..26
        building_type_avg << (col_res.inject(0.0) {|col_avg, line_val| col_avg + line_val[i]}/array_size).round(2)
      end
      building_avg << building_type_avg
    end
  end
end

# Average by weather location, fuel type, and template across building type
weather_avg = []
templates.each do |template|
  fuel_types.each do |fuel_type|
    weather_cities.each do |weather_city|
      col_res = res_array.select {|ind_res| ind_res[1] == weather_city && ind_res[2] == fuel_type && ind_res[3] == template}
      array_size = col_res.size
      weather_city_avg = [
          "all_building_types",
          weather_city,
          fuel_type,
          template
      ]
      for i in 4..26
        weather_city_avg << (col_res.inject(0.0) {|col_avg, line_val| col_avg + line_val[i]}/array_size).round(2)
      end
      weather_avg << weather_city_avg
    end
  end
end

CSV.open(res_avg_csv_name, "w") do |csv|
  csv << [
      "Building_Type",                                        #0
      "Weather_City",                                         #1
      "Fuel_Type",                                            #2
      "Template",                                             #3
      "Heating_Gas_GJ",                                       #4
      "Heating_Elec_GJ",                                      #5
      "Total_Heating_GJ",                                     #6
      "Cooling_Elec_GJ",                                      #7
      "Interior_Lighting_Elec_GJ",                            #8
      "Interior_Equipment_Elec_GJ",                           #9
      "Fans_Elec_GJ",                                         #10
      "Pumps_Elec_GJ",                                        #11
      "Heat_Rejection_GJ",                                    #12
      "Heat_Recovery_GJ",                                     #13
      "Water_Systems_Gas_GJ",                                 #14
      "Water_Systems_Elec_GJ",                                #15
      "Water_Systems_Tot_GJ",                                 #16
      "Water_Systems_m3",                                     #17
      "Total_End_Uses_Elec_GJ",                               #18
      "Total_End_Uses_Gas_GJ",                                #19
      "Total_End_Uses_Water_m3",                              #20
      "Total_Site_Energy_GJ",                                 #21
      "Site_Energy_Per_Total_Building_Area_MJ/m2",            #22
      "Site_Energy_Per_Conditioned_Building_Area_MJ/m2",      #23
      "Total_Source_Energy_GJ",                               #24
      "Source_Energy_Per_Total_Building_Area_MJ/m2",          #25
      "Source_Energy_Per_Conditioned_Building_Area_MJ/m2",    #26
  ]
  building_avg.each do |build_avg|
    csv << build_avg
  end
  weather_avg.each do |city_avg|
    csv << city_avg
  end
end
