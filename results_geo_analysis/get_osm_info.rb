require 'openstudio-standards'
require '/usr/local/openstudio-3.0.1/Ruby/openstudio'
require 'fileutils'
require 'json'
require 'csv'
require 'write_xlsx'

cost_files = Dir['/home/osdev/SundryCode/results_geo_analysis/results_files/**/*.osm']
total_out = []
airloops_out = []
total_out_json = []
cost_files.each do |cost_file|
  json_file = cost_file[0..-4] + 'json'
  json_cont = JSON.parse(File.read(json_file))
  template = (json_cont["measure_data_table"]).select { |info| info["measure_name"] == "btap_create_necb_prototype_building" && info["arg_name"] == "template" }
  fuel = json_cont['building']['principal_heating_source'].to_s.gsub(/\s+/, "")
  building_name = json_cont["building"]["name"].to_s.gsub(/\s+/, "")
  province = json_cont["geography"]["state_province_region"].to_s
  template == "BTAPPRE1980" ? name_template = "Pre" : name_template = "Mid"
  fuel == "Electricity" ? name_fuel = "elec" : name_fuel = "gas"
  case building_name.upcase
  when "FULLSERVICERESTAURANT"
    name_building = "FSR"
  when "QUICKSERVICERESTAURANT"
    name_building = "QSR"
  when "LARGEHOTEL"
    name_building = "LHO"
  when "SMALLHOTEL"
    name_building = "SHO"
  when "HIGHRISEAPARTMENT"
    name_building = "HRA"
  when "MIDRISEAPARTMENT"
    name_building = "MRA"
  when "LARGEOFFICE"
    name_building = "LOF"
  when "MEDIUMOFFICE"
    name_building = "MOF"
  when "SMALLOFFICE"
    name_building = "SOF"
  when "PRIMARYSCHOOL"
    name_building = "PSC"
  when "SECONDARYSCHOOL"
    name_building = "SSC"
  when "REATILSTANDALONE"
    name_building = "RSA"
  when "RETAILSTRIPMALL"
    name_building = "RSM"
  when "WAREHOUSE"
    name_building = "WHO"
  when "HOSPITAL"
    name_building = "HOS"
  when "OUTPATIENT"
    name_building = "OPA"
  else
    name_building = "NA"
  end
  curr_sheetname = name_template + "_" + name_building + "_" + name_fuel + "_" + province
  model = BTAP::FileIO.load_osm(cost_file)
  total_out << [
      cost_file.to_s,
      template,
      building_name,
      fuel, province,
      curr_sheetname
  ]
  tz_json = []
  model.getThermalZones.sort.each do |tz|
    ext_wallarea = 0
    floor_area = 0
    ext_floor_area = 0
    ground_floor_area = 0
    ground_wall_area = 0
    door_area = 0
    dome_area = 0
    wall_subsurf_area = 0
    skylight_area = 0
    roof_area = 0
    window_area = 0
    num_people = 0
    light_power = 0
    electric_power = 0
    volume = 0
    ventilation_air = 0
    shw = 0
    tz_floor_area = 0
    tz.spaces.sort.each do |space|
      space_floor_area = space.floorArea.to_f
      volume += space.volume.to_f
      tz_floor_area+= space_floor_area
      space.surfaces.sort.each do |surface|
        surf_type = surface.surfaceType.to_s.upcase
        if /FLOOR/ =~ surf_type
          floor_area += surface.grossArea.to_f
        end
        surface_BC = surface.outsideBoundaryCondition.to_s.upcase
        if surface_BC == 'OUTDOORS'
          if /WALL/ =~ surf_type
            ext_wallarea += surface.grossArea.to_f
            surface.subSurfaces.sort.each do |sub_surf|
              wall_subsurf_area += sub_surf.grossArea.to_f
              subsurf_type = sub_surf.subSurfaceType.to_s.upcase
              if /DOOR/ =~ subsurf_type
                door_area += sub_surf.grossArea.to_f
              elsif /WINDOW/ =~ subsurf_type
                window_area += sub_surf.grossArea.to_f
              elsif /DOME/ =~ subsurf_type
                dome_area += sub_surf.grossArea.to_f
              end
            end
          elsif /FLOOR/ =~ surf_type
            ext_floor_area += surface.grossArea.to_f
          elsif /RoofCeiling/ =~ surf_type
            roof_area += surface.grossArea.to_f
            surface.subSurfaces.sort.each do |sub_surf|
              subsurf_type = sub_surf.subSurfaceType.to_s.upcase
              if /SKYLIGHT/ =~ subsurf_type
                skylight_area += sub_surf.grossArea.to_f
              elsif /DOME/ =~ subsurf_type
                dome_area += sub_surf.grossArea.to_f
              end
            end
          end
        elsif surface_BC == "GROUND"
          if surf_type == "FLOOOR"
            ground_floor_area += surface.grossArea.to_f
          elsif surf_type == "WALL"
            ground_wall_area += surface.grossArea.to_f
          end
        end
      end
      num_people += space.peoplePerFloorArea.to_f*space_floor_area
      light_power += space.lightingPowerPerFloorArea.to_f*space_floor_area
      electric_power += space.electricEquipmentPowerPerFloorArea.to_f*space_floor_area
      shw_vector = space.waterUseEquipment
      num_shw_eq = shw_vector.size
      unless num_shw_eq.size == 0
        shw_vector.each do |shw_eq|
          shw_def = shw_eq.waterUseEquipmentDefinition
          shw += shw_def.peakFlowRate.to_f
        end
      end
      air_def = space.designSpecificationOutdoorAir.get
      ventilation_air += (air_def.outdoorAirFlowperFloorArea.to_f)*space_floor_area
    end
    area_people = 0
    shw_people = 0
    unless num_people == 0
      area_people = tz_floor_area/num_people
      shw_people = shw*60*60*1000/num_people
    end
    tz_out = [
        tz.name.to_s,
        ext_wallarea,
        floor_area,
        tz_floor_area,
        volume,
        ext_floor_area,
        ground_floor_area,
        ground_wall_area,
        door_area,
        dome_area,
        wall_subsurf_area,
        skylight_area,
        roof_area,
        window_area,
        num_people,
        area_people,
        light_power,
        (light_power/tz_floor_area),
        electric_power,
        (electric_power/tz_floor_area),
        shw,
        shw_people,
        ventilation_air*1000,
        (ventilation_air/tz_floor_area)
    ]
    tz_json << {
        tz_name: tz_out[0],
        ext_wall_area_m2: tz_out[1],
        floor_area_m2: tz_out[2],
        tz_floor_area_m2: tz_out[3],
        volume_m3: tz_out[4],
        exp_floor_area_m2: tz_out[5],
        ground_floor_area_m2: tz_out[6],
        ground_wall_area_m2: tz_out[7],
        door_area_m2: tz_out[8],
        dome_area_m2: tz_out[9],
        wall_subsurf_area_m2: tz_out[10],
        skylight_area_m2: tz_out[11],
        roof_area_m2: tz_out[12],
        window_area_m2: tz_out[13],
        num_people: tz_out[14],
        area_people_m2_per_person: tz_out[15],
        light_power_W: tz_out[16],
        light_power_W_per_m2: tz_out[17],
        electric_power_W: tz_out[18],
        electric_power_W_per_m2: tz_out[19],
        shw_m3_per_s: tz_out[20],
        shw_L_per_hour_per_person: tz_out[21],
        ventilation_air_L_per_s: tz_out[22],
        ventilation_air_m3_per_s_per_m2: tz_out[23]
    }
    total_out << tz_out
  end
  total_out_json << {
      file_name: cost_file,
      building_type: building_name,
      template: template,
      fuel: fuel,
      province: province,
      sheet_name: curr_sheetname,
      tz_info: tz_json
  }
  airloops_out << json_file
  airloops_fileout = []
  json_cont["air_loops"].each do |air_loop|
    al_name = air_loop["name"].to_s
    heating_coils = air_loop["heating_coils"]["coil_heating_gas"] unless air_loop["heating_coils"]["coil_heating_gas"].empty?
    heating_coils = air_loop["heating_coils"]["coil_heating_electric"] unless air_loop["heating_coils"]["coil_heating_electric"].empty?
    if air_loop["supply_fan"].nil?
      supply_fan_motor_eff = "none"
      supply_fan_eff = "none"
      supply_fan_prise = "none"
    else
      supply_fan_motor_eff = air_loop["supply_fan"]["motor_efficiency"]
      supply_fan_eff = air_loop["supply_fan"]["fan_efficiency"]
      supply_fan_prise = air_loop["supply_fan"]["pressire_rise"]
    end
    if air_loop["return_fan"].nil?
      return_fan_motor_eff = "none"
      return_fan_eff = "none"
      return_fan_prise = "none"
    else
      return_fan_motor_eff = air_loop["return_fan"]["motor_efficiency"]
      return_fan_eff = air_loop["return_fan"]["fan_efficiency"]
      return_fan_prise = air_loop["return_fan"]["pressire_rise"]
    end
    air_loop["economizer"].nil? ? economizer = "none" : economizer = air_loop["economizer"]["control_type"]
    ind_out = {
        airloop_name: al_name,
        type: al_name[0..4],
        heating_coil: heating_coils,
        cooling_coil_dx: air_loop["cooling_coils"]["dx_single_speed"],
        cooling_coils_water: air_loop["cooling_coils"]["coil_cooling_water"],
        area_served: air_loop["total_floor_area_served"],
        outdoor_air: air_loop["outdoor_air_L_per_s"],
        supply_fan_motor_eff: supply_fan_motor_eff,
        supply_fan_eff: supply_fan_eff,
        supply_fan_prise: supply_fan_prise,
        return_fan_motor_eff: return_fan_motor_eff,
        return_fan_eff: return_fan_eff,
        return_fan_prise: return_fan_prise,
        economizer: economizer
    }
    airloops_fileout << ind_out
  end
  airloops_out << {
      file_name: json_file,
      building_type: building_name,
      template: template,
      fuel: fuel,
      province: province,
      sheet_name: curr_sheetname,
      airloops: airloops_fileout
  }
end

CSV.open('./results_tz_geo.csv', "w") do |csv|
  csv << [
      "Thermal_Zone_Name",
      "Exterior_Wall_Area",
      "Floor_Area",
      "TZ_Floor_Area",
      "Volume",
      "Exterior_Floor_Area",
      "Ground_Floor_Area",
      "Ground_Wall_Area",
      "Door_Area",
      "Dome_Area",
      "Wall_Sub_Surface_Area",
      "Skylight_Area",
      "Roof_Area",
      "Window_Area",
      "Num_People",
      "TZ_Floor_Area/People",
      "Light_Power",
      "Light_Power/Area",
      "Electric_Power",
      "Electric_Power/Aera",
      "SHW_Peak_Flow",
      "SHW_Peak_Flow/people_L/hr/occ",
      "Ventilation_Air_L/s",
      "Ventilation_Air/Area_m/s"
  ]
  total_out.each do |csv_out|
    out = []
    if csv_out.kind_of?(Array)
      out = csv_out
    else
      out << csv_out
    end
    csv << out
  end
end

templates = [
    "BTAPPRE1980",
    "BTAP1980TO2010"
]

provinces = []
provinces_pre = total_out_json.uniq{|ind_res| ind_res[:province]}
provinces_pre.each {|provinces_ind| provinces << provinces_ind[:province]}

fuel_types = []
fuel_type_pre = total_out_json.uniq{|ind_res| ind_res[:fuel]}
fuel_type_pre.each {|fuel_ind| fuel_types << fuel_ind[:fuel]}

building_types = []
building_type_pre = post_vint.uniq{|ind_res| ind_res[:building_type]}
building_type_pre.each {|building_ind| building_types << building_ind[:building_type]}

# Sort json output by building type, then weather city, then fuel type, and finally vintage
sorted_json = []
building_types.sort.each do |building_type|
  sort_building_type = total_out.select{|ind_rec| ind_rec[:building_type] == building_type}
  provinces.sort.each do |prov|
    sort_weather_loc = sort_building_type.select{|ind_rec| ind_rec[:province] == prov}
    fuel_types.sort.each do |fuel_type|
      sort_fuel_types = sort_weather_loc.select{|ind_rec| ind_rec[:fuel] == fuel_type}
      templates.each do |template|
        sorted_json << sort_fuel_types.select{|ind_rec| ind_rec[:template] == template}[0]
      end
    end
  end
end

=begin
tz_json << {
    tz_name: tz_out[0],
    ext_wall_area_m2: tz_out[1],
    floor_area_m2: tz_out[2],
    tz_floor_area_m2: tz_out[3],
    volume_m3: tz_out[4],
    exp_floor_area_m2: tz_out[5],
    ground_floor_area_m2: tz_out[6],
    ground_wall_area_m2: tz_out[7],
    door_area_m2: tz_out[8],
    dome_area_m2: tz_out[9],
    wall_subsurf_area_m2: tz_out[10],
    skylight_area_m2: tz_out[11],
    roof_area_m2: tz_out[12],
    window_area_m2: tz_out[13],
    num_people: tz_out[14],
    area_people_m2_per_person: tz_out[15],
    light_power_W: tz_out[16],
    light_power_W_per_m2: tz_out[17],
    electric_power_W: tz_out[18],
    electric_power_W_per_m2: tz_out[19],
    shw_m3_per_s: tz_out[20],
    shw_L_per_hour_per_person: tz_out[21],
    ventilation_air_L_per_s: tz_out[22],
    ventilation_air_m3_per_s_per_m2: tz_out[23]
}
=end

workbook = WriteXLSX.new('./res_out_2020-07-29.xlsx')
sorted_json.each do |json_sort|
  airloop_out = airloops_out.select{|ind_rec| ind_rec[:sheet_name] == json_sort[:sheet_name]}[0]
  worksheet = workbook.add_worksheet(sheetname=json_sort[:sheetname])
  col_titles = [
      "tz_name",
      "ext_wall_area_m2",
      "floor_area_m2",
      "tz_floor_area_m2",
      "volume_m3",
      "exp_floor_area_m2",
      "ground_floor_area_m2",
      "ground_wall_area_m2",
      "door_area_m2",
      "dome_area_m2",
      "wall_subsurf_area_m2",
      "skylight_area_m2",
      "roof_area_m2",
      "window_area_m2",
      "num_people",
      "area_people_m2_per_person",
      "light_power_W",
      "light_power_W_per_m2",
      "electric_power_W",
      "electric_power_W_per_m2",
      "shw_m3_per_s",
      "shw_L_per_hour_per_person",
      "ventilation_air_L_per_s",
      "ventilation_air_m3_per_s_per_m2"
  ]
  col = 0
  row = 2
  col_titles.each do |col_title|
    worksheet.write(row, col, col_title)
    col += 1
  end
end



in_file = './data/boilers.json'
json_info = JSON.parse(File.read(in_file))
table_info = json_info["tables"]["boilers"]["table"]
out_file = './' + in_file[7..-5] + 'xlsx'
workbook = WriteXLSX.new(out_file)
worksheet = workbook.add_worksheet
col = row = 0
col_titles.each do |col_title|
  worksheet.write(row, col, col_title)
  col += 1
end
row += 1
table_info.each do |table_entry|
  col = 0
  json_titles.each do |json_title|
    xlsx_output = table_entry[json_title]
    if xlsx_output == '-'
      xlsx_output = 0
    else
      xlsx_output.is_a?(Float) ? xlsx_output.to_f : xlsx_output.to_s
    end
    worksheet.write(row, col, xlsx_output)
    col += 1
  end
  row += 1
end
workbook.close