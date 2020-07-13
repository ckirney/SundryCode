require 'fileutils'
require 'json'
require 'csv'

in_file = './simulations_BTAP_vintage_analysis_2020-04-03.json'
out_file = './out_res.csv'
in_res = JSON.parse(File.read(in_file))
CSV.open(out_file, "w") do |csv|
  csv << [
      "Building_Type",
      "Weather_City",
      "Fuel_Type",
      "Template",
      "Above_Ground_Wall_Area_m2",
      "Roof_Area_m2",
      "Above_Grade_Floor_Area_m2",
      "Ground_Wall_Area_m2",
      "Ground_Roof_Area_m2",
      "Ground_Floor_Area_m2",
      "Interior_Floor_Area_m2",
      "Window_Area_m2",
      "Skylight_Area_m2",
      "Doors_Area_m2",
      "Overhead_Door_Area_m2",
      "Total_Exterior_Area_m2",
      "Total_Ground_Area_m2",
      "Total_Outdoor_Area_m2",
      "outdoor_walls_average_conductance_w_per_m2_k",
      "outdoor_roofs_average_conductance_w_per_m2_k",
      "ground_walls_average_conductance_w_per_m2_k",
      "ground_floors_average_conductance_w_per_m2_k",
      "windows_average_conductance_w_per_m2_k",
      "skylights_average_conductance_w_per_m2_k",
      "building_outdoor_average_conductance_w_per_m2_k",
      "building_ground_average_conductance_w_per_m2_k",
      "building_average_conductance_w_per_m2_k",
      "FDWR",
      "SRR",
      "Windows_plus_Doors_Area_m2",
      "Calc_FDWR",
      "Calc_SRR"
  ]
  in_res.each do |ind_res|
    csv << [
        ind_res["building"]["name"],
        ind_res["geography"]["city"],
        ind_res["building"]["principal_heating_source"],
        ind_res["template"],
        ind_res["envelope"]["outdoor_walls_area_m2"],
        ind_res["envelope"]["outdoor_roofs_area_m2"],
        ind_res["envelope"]["outdoor_floors_area_m2"],
        ind_res["envelope"]["ground_walls_area_m2"],
        ind_res["envelope"]["ground_roofs_area_m2"],
        ind_res["envelope"]["ground_floors_area_m2"],
        ind_res["envelope"]["interior_floors_area_m2"],
        ind_res["envelope"]["windows_area_m2"],
        ind_res["envelope"]["skylights_area_m2"],
        ind_res["envelope"]["doors_area_m2"],
        ind_res["envelope"]["overhead_doors_area_m2"],
        ind_res["envelope"]["total_exterior_area_m2"],
        ind_res["envelope"]["total_ground_area_m2"],
        ind_res["envelope"]["total_outdoor_area_m2"],
        ind_res["envelope"]["outdoor_walls_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["outdoor_roofs_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["ground_walls_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["ground_floors_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["windows_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["skylights_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["building_outdoor_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["building_ground_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["building_average_conductance_w_per_m2_k"],
        ind_res["envelope"]["fdwr"],
        ind_res["envelope"]["srr"],
        (ind_res["envelope"]["windows_area_m2"].to_f + ind_res["envelope"]["doors_area_m2"].to_f),
        ((ind_res["envelope"]["windows_area_m2"].to_f + ind_res["envelope"]["doors_area_m2"].to_f)/(ind_res["envelope"]["outdoor_walls_area_m2"].to_f + ind_res["envelope"]["windows_area_m2"].to_f + ind_res["envelope"]["doors_area_m2"].to_f)).round(3)*100,
        ((ind_res["envelope"]["skylights_area_m2"].to_f)/(ind_res["envelope"]["outdoor_roofs_area_m2"].to_f + ind_res["envelope"]["skylights_area_m2"].to_f)).round(3)*100
    ]
  end
end