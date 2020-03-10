require 'json'
require 'csv'
require 'fileutils'

in_json = './simulations.json'
out_csv = './edmonton_datapoints.csv'
csv_out = []

sim_data = JSON.parse(File.read(in_json))
out_data = sim_data.select {|datapoint|
  (datapoint["geography"]["city"].to_s.downcase.include? "edmonton") && ((datapoint["building_type"] == "LargeOffice") || (datapoint["building_type"] == "MediumOffice") || (datapoint["building_type"] == "SmallOffice") || (datapoint["building_type"] == "PrimarySchool") || (datapoint["building_type"] == "SecondarySchool") || (datapoint["building_type"] == "HighriseApartment") || (datapoint["building_type"] == "MidriseApartment"))
}

out_data.each do |ed_data|
  csv_out << [
      ed_data["geography"]["city"],
      ed_data["building_type"],
      ed_data["template"],
      ed_data["building"]["principal_heating_source"],
      ed_data["run_uuid"]
  ]
end

CSV.open(out_csv, "w") do |csv|
  csv << [
      "City",
      "Building_Type",
      "Template",
      "Principle_Heating_Source",
      "Datapoint_ID"
  ]
  csv_out.each do |csv_line|
    csv << csv_line
  end
end

