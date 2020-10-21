require 'fileutils'
require 'json'
require 'csv'

provinces = [
    "AB",
    "BC",
    "MB",
    "NB",
    "NL",
    "NT",
    "NS",
    "ON",
    "PE",
    "QC",
    "SK",
    "YT",
    "NU"
]

in_csv = "./census_hdd_out_adj_2020-10-21.csv"
out_json = "./climate_zone_pop_frac_prov.json"
in_data = CSV.read(in_csv)
out_array = []
tot_pop = 0

for i in (2000..7000).step(1000)
  top_lim = i + 999
  if i == 7000
    top_lim = 99999
  end
  clim_zone_info = in_data.select{|row| (row[6].to_f <= top_lim) && (row[6].to_f >= i)}
  if clim_zone_info.empty?
    next
  end
  pop = 0
  clim_zone_info.each do |city|
    pop += city[0].to_f
  end
  out_array << {
      min_hdd18: i,
      max_hdd18: top_lim,
      population: pop,
      pop_frac: 0
  }
  tot_pop += pop
end
out_array.each do |clm_zone|
  clm_zone[:pop_frac] = clm_zone[:population]/tot_pop
end
File.write(out_json, JSON.pretty_generate(out_array))