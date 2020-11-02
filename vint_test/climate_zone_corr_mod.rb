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

provinces.each do |province|
  prov_pop = 0
  prov_clim = []
  prov_data = in_data.select{|data_row| data_row[1].to_s == province}
  for i in (2000..7000).step(1000)
    top_lim = i + 999
    if i == 7000
      top_lim = 99999
    end
    clim_zone_info = prov_data.select{|row| (row[3].to_f <= top_lim) && (row[3].to_f >= i)}
    pop = 0
    unless clim_zone_info.empty?
      clim_zone_info.each do |city|
        pop += city[2].to_f
      end
    end

    prov_clim << {
        min_hdd18: i,
        max_hdd18: top_lim,
        population: pop,
        nat_pop_frac: 0
    }
    tot_pop += pop
    prov_pop += pop
  end
  prov_clim.each do |clm_zone|
    clm_zone[:pop_frac] = clm_zone[:population]/prov_pop
  end
  out_array << {
      province: province,
      prov_pop: prov_pop,
      prov_climate_zones: prov_clim
  }
end

out_array.each do |prov|
  prov[:prov_climate_zones].each do |prov_cz|
    prov_cz[:nat_pop_frac] = prov_cz[:population].to_f/tot_pop.to_f
  end
  out_name = "./" + prov[:province].to_s + "_climate_info.json"
  File.write(out_name, JSON.pretty_generate(prov))
end
File.write(out_json, JSON.pretty_generate(out_array))