require 'json'
class GetSpaceTypes
  in_json_path = "./ext_sptypes/"
  necb_vers = ["2011", "2015", "2017"]
  necb_vers.each do |necb_ver|
    in_json_file = in_json_path + "space_types" + necb_ver + ".json"
    file = File.read(in_json_file)
    data_tables = JSON.parse(file)
    sp_types = data_tables["tables"]["space_types"]["table"]
    json_out = []
    sp_types.each {|data| json_out << {building: data['building_type'], space_type: data['space_type'], duct_vel_fpm: 0}}
    out_json_file = in_json_path + "out_space_types" + necb_ver + ".json"
    File.open(out_json_file,"w") {|each_file| each_file.write(JSON.pretty_generate(json_out))}
  end
end