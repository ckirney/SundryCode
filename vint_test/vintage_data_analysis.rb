require 'fileutils'
require 'json'
require 'csv'

def diff(one, other)
  (one.keys + other.keys).uniq.inject({}) do |memo, key|
    unless one.key?(key) && other.key?(key) && one[key] == other[key]
      memo[key] = [one.key?(key) ? one[key] : :_no_key, other.key?(key) ? other[key] : :_no_key]
    end
    memo
  end
end

post_vint_file = './btap_postvint_2.json'

post_vint = JSON.parse(File.read(post_vint_file))

templates = []
code_ver_pre = post_vint.uniq{|ind_res| ind_res["template"]}
code_ver_pre.each {|code_ver_ind| templates << code_ver_ind["template"]}
weather_cities = []
weather_city_pre = post_vint.uniq{|ind_res| ind_res["geography"]["city"]}
weather_city_pre.each {|weather_ind| weather_cities << weather_ind["geography"]["city"]}
fuel_types = []
fuel_type_pre = post_vint.uniq{|ind_res| ind_res["building"]["principal_heating_source"]}
fuel_type_pre.each {|fuel_ind| fuel_types << fuel_ind["building"]["principal_heating_source"]}
building_types = []
building_type_pre = post_vint.uniq{|ind_res| ind_res["building_type"]}
building_type_pre.each {|building_ind| building_types << building_ind["building_type"]}

post_index_array = []
post_vint_mod = []

sort_vint = []

building_types.each do |building_type|
  sort_building_type = post_vint.select{|ind_rec| ind_rec["building_type"] == building_type}
  weather_cities.each do |weather_city|
    sort_weather_loc = sort_building_type.select{|ind_rec| ind_rec["geography"]["city"] == weather_city}
    fuel_types.each do |fuel_type|
      sort_fuel_types = sort_weather_loc.select{|ind_rec| ind_rec["building"]["principal_heating_source"] == fuel_type}
      templates.sort.each do |template|
        sort_vint << sort_fuel_types.select{|ind_rec| ind_rec["template"] == template}[0]
      end
    end
  end
end

test_out = sort_vint[241]

res_csv_name = "./post_2_results.csv"
CSV.open(res_csv_name, "w") do |csv|
  csv << [
      "Building_Type",
      "Weather_City",
      "Fuel_Type",
      "Template",
      "Heating_Gas_GJ",
      "Heating_Elec_GJ",
      "Cooling_Elec_GJ",
      "Interior_Lighting_Elec_GJ",
      "Interior_Equipment_Elec_GJ",
      "Fans_Elec_GJ", "Pumps_Elec_GJ",
      "Water_Systems_m3",
      "Water_Systems_Gas_GJ",
      "Water_Systems_Elec_GJ",
      "Total_End_Uses_Elec_GJ",
      "Total_End_Uses_Gas_GJ",
      "Total_End_Uses_Water_m3",
      "Total_Site_Energy_GJ",
      "Site_Energy_Per_Total_Building_Area_MJ/m2",
      "Site_Energy_Per_Conditioned_Building_Area_MJ/m2",
      "Total_Source_Energy_GJ",
      "Source_Energy_Per_Total_Building_Area_MJ/m2",
      "Source_Energy_Per_Conditioned_Building_Area_MJ/m2",
      "Analysis_Name",
      "Analysis_ID",
      "Data_Point_ID"
  ]
  sort_vint.each do |vint_rec|
    csv_out = [
        vint_rec["building_type"],
        vint_rec["geography"]["city"],
        vint_rec["building"]["principal_heating_source"],
        vint_rec["template"]
    ]
    vint_rec["sql_data"][0]["table"][0]["natural_gas_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][0]["natural_gas_GJ"] #heating
    vint_rec["sql_data"][0]["table"][0]["electricity_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][0]["electricity_GJ"] #heating
    csv_out << vint_rec["sql_data"][0]["table"][1]["electricity_GJ"] #cooling
    csv_out << vint_rec["sql_data"][0]["table"][2]["electricity_GJ"] #lighting
    csv_out << vint_rec["sql_data"][0]["table"][3]["electricity_GJ"] #equip
    csv_out << vint_rec["sql_data"][0]["table"][4]["electricity_GJ"] #fans
    if vint_rec["sql_data"][0]["table"][5]["name"] == "Pumps" #Some buildings do not have pump energy so check if is included to ensure indices for later items match
      csv_out << vint_rec["sql_data"][0]["table"][5]["electricity_GJ"] #pumps
      csv_out << vint_rec["sql_data"][0]["table"][6]["water_m3"] #water
      vint_rec["sql_data"][0]["table"][6]["natural_gas_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][6]["natural_gas_GJ"] #water
      vint_rec["sql_data"][0]["table"][6]["electricity_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][6]["electricity_GJ"] #water
      vint_rec["sql_data"][0]["table"][7]["electricity_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][7]["electricity_GJ"] #end uses
      vint_rec["sql_data"][0]["table"][7]["natural_gas_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][7]["natural_gas_GJ"] #end uses
      vint_rec["sql_data"][0]["table"][7]["water_m3"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][7]["water_m3"] #end uses
    else
      csv_out << 0 #pumps
      csv_out << vint_rec["sql_data"][0]["table"][5]["water_m3"] #water
      vint_rec["sql_data"][0]["table"][5]["natural_gas_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][5]["natural_gas_GJ"] #water
      vint_rec["sql_data"][0]["table"][5]["electricity_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][5]["electricity_GJ"] #water
      vint_rec["sql_data"][0]["table"][6]["electricity_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][6]["electricity_GJ"] #end uses
      vint_rec["sql_data"][0]["table"][6]["natural_gas_GJ"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][6]["natural_gas_GJ"] #end uses
      vint_rec["sql_data"][0]["table"][6]["water_m3"].nil? ? csv_out << 0: csv_out << vint_rec["sql_data"][0]["table"][6]["water_m3"] #end uses
    end
    csv_out << vint_rec["sql_data"][1]["table"][0]["total_energy_GJ"] #Site Energy
    csv_out << vint_rec["sql_data"][1]["table"][0]["energy_per_total_building_area_MJ/m2"] #Site Energy
    csv_out << vint_rec["sql_data"][1]["table"][0]["energy_per_conditioned_building_area_MJ/m2"] #Site Energy
    csv_out << vint_rec["sql_data"][1]["table"][2]["total_energy_GJ"] #Site Energy
    csv_out << vint_rec["sql_data"][1]["table"][2]["energy_per_total_building_area_MJ/m2"] #Site Energy
    csv_out << vint_rec["sql_data"][1]["table"][2]["energy_per_conditioned_building_area_MJ/m2"] #Site Energy
    csv_out << vint_rec["analysis_name"]
    csv_out << vint_rec["analysis_id"]
    csv_out << vint_rec["run_uuid"]
    csv << csv_out
  end
end