require 'json'
require 'fileutils'

in_file = "./bps_2017_cities_analyse.json"
out_file = "./bps_2017_climate_info.json"

in_json = JSON.parse(File.read(in_file))

climates = in_json.uniq{|city| city["climate"].to_s}

out_info = {
    total_climates: climates.size,
    climates: []
}

climates.each do |climate|
  climate_records = in_json.select{|record| record["climate"] == climate["climate"]}
  climate_records
  out_info[:climates] << {
      climate: climate["climate"],
      number: climate_records.size,
      schools: climate_records.sum{|rec| rec["schools"]},
      admin_facilities: climate_records.sum{|rec| rec["admin_facilities"]},
      classrooms: climate_records.sum{|rec| rec["classrooms"]},
      residences: climate_records.sum{|rec| rec["residences"]},
      admin_facilities_council_chambers: climate_records.sum{|rec| rec["admin_facilities_council_chambers"]},
      total_number: climate_records.sum{|rec| rec["total_number"]}
  }
end

out_info_sort = {
    total_climates: climates.size,
    climates: out_info[:climates].sort_by{|rec| -rec[:total_number]}
}

File.write(out_file, JSON.pretty_generate(out_info_sort))