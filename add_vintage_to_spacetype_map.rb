require 'json'
require 'fileutils'

upgrade_map_file = "./space_type_upgrade_map.json"
upgrade_map_file_b = "./space_type_upgrade_map_b.json"
upgrade_map = JSON.parse(File.read(upgrade_map_file))
upgrade_map['tables']['space_type_upgrade_map']['table'].each do |upgrade_spacetype|
  upgrade_spacetype["BTAPPRE1980_building_type"] = upgrade_spacetype['NECB2011_building_type']
  upgrade_spacetype["BTAPPRE1980_space_type"] = upgrade_spacetype['NECB2011_space_type']
  puts upgrade_spacetype
end

File.open(upgrade_map_file, "w") do |f|
  f.write(JSON.pretty_generate(upgrade_map))
end
