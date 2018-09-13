require_relative '../../../test/helpers/minitest_helper'
require_relative '../../../test/helpers/create_doe_prototype_helper'
# This file assumes it is in /home/dev/openstudio-standards/lib/openstudio-standards/utilities/
class Check_mult < Minitest::Test
  Templates = ['NECB2011', 'NECB2015', 'NECB2017']
  Epw_files = ['CAN_AB_Calgary.Intl.AP.718770_CWEC2016.epw']

  # @return [Bool] true if successful. 
#  def checkmult()
    output_array = []
    climate_zone = 'none'
    #Iterate through NECB2011 and NECB2015 as well as weather locations heated by gas and electricity.
    Templates.sort.each do |template|
      Epw_files.sort.each do |epw_file|
        model_path = "/home/osdev/openstudio-standards/lib/openstudio-standards/standards/necb/#{template}/data/geometry/*.osm"
        files_info = []
        Dir.glob(model_path) do |item|
          puts item
          model = BTAP::FileIO.load_osm("#{item}")
          BTAP::Environment::WeatherFile.new(epw_file).set_weather_file(model)
          tzs_info = []
          model.getThermalZones.sort.each do |therm_zone|
            if therm_zone.multiplier > 1
              tz_name = therm_zone.name.get.to_s
              tz_mult = therm_zone.multiplier
              space_names = []
              therm_zone.spaces.sort.each do |space|
                space_names << space.name.get.to_s
              end
              tz_info = {
                  "tz_name" => tz_name,
                  "tz_mult" => tz_mult,
                  "tz_spaces" => space_names
              }
              tzs_info << tz_info
            end
          end
          file_info = {
              "File_name" => File.basename(item),
              "Thermal_zone_info" => tzs_info
          }
          files_info << file_info
        end
        set_output = {
            "template" => template,
            "epw_file" => epw_file,
            "file_info" => files_info
        }
        # Add this hash to an array containing the same info for all of the sets of space types applied to the model.
        output_array << set_output
      end #loop to the next epw_file
    end #loop to the next Template
    #Write test report file. 
    test_result_file = File.join(File.dirname(__FILE__),'tz_multiplier_results.json')
    File.open(test_result_file, 'w') {|f| f.write(JSON.pretty_generate(output_array)) }
#  end
end