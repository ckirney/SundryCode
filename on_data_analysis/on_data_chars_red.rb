require 'json'
require 'fileutils'

in_file = 'bps_2017.json'
out_file_dist = in_file[0..-6] + '_cities_dist.json'
out_file_ordered = in_file[0..-6] + '_cities_dist_ord.json'
out_file_top50 = in_file[0..-6] + '_top_50_city_build_numbers.json'

sub_sector_names = [
    "School Board",
    "Municipality",
    "Municipal Service Board"
]

on_data = JSON.parse(File.read(in_file))

sub_sectors = on_data.select{|inst| inst["sub_sector"] == sub_sector_names[0] || inst["sub_sector"] == sub_sector_names[1] || inst["sub_sector"] == sub_sector_names[2]}

operation_type_names = [
    "School",
    "Administrative offices and related facilities",
    "Classrooms and related facilities",
    "Student residences",
    "Administrative offices and related facilities, including municipal council chambers"
]

op_types = sub_sectors.select{|inst| inst["operation_type"] == operation_type_names[0] || inst["operation_type"] == operation_type_names[1] || inst["operation_type"] == operation_type_names[2] || inst["operation_type"] == operation_type_names[3] || inst["operation_type"] == operation_type_names[4]}

uniq_city = op_types.uniq{|inst| inst["city"]}
uniq_city_dist = {
    name: "Cities",
    number: uniq_city.size,
    distribution: [],
}
uniq_city.each do |city|
  school_num = op_types.select{|inst| inst["city"] == city["city"] && inst["operation_type"] == operation_type_names[0]}.size
  admin_facilities_num = op_types.select{|inst| inst["city"] == city["city"] && inst["operation_type"] == operation_type_names[1]}.size
  classroom_num = op_types.select{|inst| inst["city"] == city["city"] && inst["operation_type"] == operation_type_names[2]}.size
  res_num = op_types.select{|inst| inst["city"] == city["city"] && inst["operation_type"] == operation_type_names[3]}.size
  council_chambers_num = op_types.select{|inst| inst["city"] == city["city"] && inst["operation_type"] == operation_type_names[4]}.size
  total_num = op_types.select{|inst| inst["city"] == city["city"]}.size
  uniq_city_dist[:distribution] << {
      city: city["city"],
      schools: school_num,
      admin_facilities: admin_facilities_num,
      classrooms: classroom_num,
      residences:  res_num,
      admin_facilities_council_chambers: council_chambers_num,
      total_number: total_num,
  }
end

size_ranges = [
    [101, 1000000],
    [76, 100],
    [51, 75],
    [41, 50],
    [31, 40],
    [21, 30],
    [11, 20],
    [0, 10]
]

city_build_num_dist = {
    name: "Cities",
    total_cities: 0,
    size_dist: []
}
num_cities_comp = 0
size_ranges.each do |size_range|
  cities = uniq_city_dist[:distribution].select{|inst| inst[:total_number] >= size_range[0] && inst[:total_number] <= size_range[1]}
  cities_size = cities.size
  num_cities_comp += cities_size
  city_build_num_dist[:size_dist] << {
      min_size: size_range[0],
      max_size: size_range[1],
      num: cities_size,
      cities: cities
  }
end
city_build_num_dist[:total_cities] = num_cities_comp

cities_ord = uniq_city_dist[:distribution].sort_by{|inst| inst[:total_number]}.reverse

File.write(out_file_dist, JSON.pretty_generate(uniq_city_dist))
File.write(out_file_ordered, JSON.pretty_generate(city_build_num_dist))
File.write(out_file_top50, JSON.pretty_generate(cities_ord[0..49]))