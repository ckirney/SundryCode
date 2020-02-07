require 'json'
require 'fileutils'

infile = "./simulations_test_new.json"
new_data = JSON.parse(File.read(infile))

new_data.each do |new_dat|
  city = new_dat['geography']['city']
  plant_loops = new_dat['plant_loops']
  boilers = new_dat['plant_loops'].find {|plant_loop| plant_loop['name'] == 'Hot Water Loop'}
  water_heating_fuel_type = nil
  unless boilers['boilers'].empty?
    boiler_fuel_type = boilers['boilers'].uniq {|boiler| boiler['fueltype']}
    if boiler_fuel_type.size == 0
      return "multiple boilers with different fuel types"
    else
      water_heating_fuel_type = boiler_fuel_type[0]['fueltype']
    end
  end
  air_heaters_gas = (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_gas'].any?}).nil? ? 0 : (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_gas'].any?}).size
  air_heaters_electric = (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_electric'].any?}).nil? ? 0 : (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_electric'].any?}).size
  air_heaters_water = (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_water'].any?}).nil? ? 0 : (new_dat['air_loops'].find {|air_loop| air_loop['heating_coils']['coil_heating_water'].any?}).size
end

#out_file = "./out_single_small_new_pretty.json"

#File.write(out_file, JSON.pretty_generate(in_data[5]))