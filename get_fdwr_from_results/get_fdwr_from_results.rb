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
      "Window_Area_m2",
      "Doors_Area_m2",
      "Windows_plus_Doors_Area_m2",
      "Skylight_Area_m2",
      "FDWR",
      "SRR",
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
        ind_res["envelope"]["windows_area_m2"],
        ind_res["envelope"]["doors_area_m2"],
        (ind_res["envelope"]["windows_area_m2"].to_f + ind_res["envelope"]["doors_area_m2"].to_f),
        ind_res["envelope"]["skylights_area_m2"],
        ind_res["envelope"]["fdwr"],
        ind_res["envelope"]["srr"],
        ((ind_res["envelope"]["windows_area_m2"].to_f + ind_res["envelope"]["doors_area_m2"].to_f)/ind_res["envelope"]["outdoor_walls_area_m2"].to_f).round(3),
        ((ind_res["envelope"]["skylights_area_m2"].to_f)/(ind_res["envelope"]["outdoor_roofs_area_m2"].to_f)).round(3)
    ]
  end
end