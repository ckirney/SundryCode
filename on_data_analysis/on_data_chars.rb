require 'json'
require 'fileutils'

in_file = 'bps_2017.json'
out_file = in_file[0..-6] + '_chars.json'

on_data = JSON.parse(File.read(in_file))
uniq_sector = on_data.uniq{|inst| inst["sector"]}
uniq_sector_dist = {
    name: "Sectors",
    number: uniq_sector.size,
    distribution: []
}
uniq_sector.each do |sector|
  uniq_sector_dist[:distribution] << {
      sector: sector["sector"],
      number: on_data.select{|inst| inst["sector"] == sector["sector"]}.size
  }
end

uniq_sub_sector = on_data.uniq{|inst| inst["sub_sector"]}
uniq_sub_sector_dist = {
    name: "Sub_Sectors",
    number: uniq_sub_sector.size,
    distribution: []
}
uniq_sub_sector.each do |subsector|
  uniq_sub_sector_dist[:distribution] << {
      sub_sector: subsector["sub_sector"],
      number: on_data.select{|inst| inst["sub_sector"] == subsector["sub_sector"]}.size
  }
end

uniq_op_type = on_data.uniq{|inst| inst["operation_type"]}
uniq_op_type_dist = {
    name: "Operation_Types",
    number: uniq_op_type.size,
    distribution: []
}
uniq_op_type.each do |op_type|
  uniq_op_type_dist[:distribution] << {
      operation_type: op_type["operation_type"],
      number: on_data.select{|inst| inst["operation_type"] == op_type["operation_type"]}.size
  }
end

uniq_city = on_data.uniq{|inst| inst["city"]}
uniq_city_dist = {
    name: "Cities",
    number: uniq_city.size,
    distribution: []
}
uniq_city.each do |city|
  uniq_city_dist[:distribution] << {
      city: city["city"],
      number: on_data.select{|inst| inst["city"] == city["city"]}.size
  }
end

out_data = {
    sector: uniq_sector_dist,
    sub_sector: uniq_sub_sector_dist,
    operation_type: uniq_op_type_dist,
    city: uniq_city_dist
}

File.write(out_file, JSON.pretty_generate(out_data))