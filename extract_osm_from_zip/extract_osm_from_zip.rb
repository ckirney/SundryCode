require 'fileutils'
require 'json'
require 'zip'

# Source copied and modified from https://github.com/rubyzip/rubyzip.
# This extracts the data from a zip file that presumably contains a json file.  It returns the contents of that file in
# an array of hashes (if there were multiple files in the zip file.)
def unzip_files(zip_name:, search_name: nil)
  output = {
      status: false,
      out_info: []
  }
  Zip::File.open(zip_name) do |zip_file|
    zip_file.each do |entry|
      if search_name.nil?
        output[:status] = true
        content = entry.get_input_stream.read
        output[:out_info] << content
      else
        if entry.name == search_name
          output[:status] = true
          content = entry.get_input_stream.read
          output[:out_info] << content
        end
      end
    end
  end
  return output
end

zip_files = Dir["./files/*.zip"]
zip_files.each do |zip_file|
  qaqc_raw = unzip_files(zip_name: zip_file, search_name: "qaqc.json")
  qaqc_info = JSON.parse(qaqc_raw[:out_info][0])
  in_osm_info = unzip_files(zip_name: zip_file, search_name: "in.osm")
  in_osm = in_osm_info[:out_info][0]
  heat_source = qaqc_info["building"]["principal_heating_source"].gsub(" ", "")
  city_loc = qaqc_info["geography"]["city"].gsub(" ", "") + "_" + qaqc_info["geography"]["state_province_region"]
  out_osm_name = './out_osm/' + qaqc_info["building_type"] + "_" + qaqc_info["template"] + "_" + heat_source + "_" + city_loc + ".osm"
  File.write(out_osm_name, in_osm_info)
end