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
  template_search = (json_cont["measure_data_table"]).select { |info| info["measure_name"] == "btap_create_necb_prototype_building" && info["arg_name"] == "template" }
  template = template_search[0]["value"]
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
  total_roof_area_m2 = 0
  total_extwall_area_m2 = 0
  total_belowwall_area_m2 = 0
  total_slab_area_m2 = 0
  total_skylight_area_m2 = 0
  total_window_area_m2 = 0
  total_door_area_m2 = 0
  total_dome_area_m2 = 0
  total_subsurface_area_m2 = 0
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
            total_extwall_area_m2 += surface.grossArea.to_f
            surface.subSurfaces.sort.each do |sub_surf|
              wall_subsurf_area += sub_surf.grossArea.to_f
              total_subsurface_area_m2 += sub_surf.grossArea.to_f
              subsurf_type = sub_surf.subSurfaceType.to_s.upcase
              if /DOOR/ =~ subsurf_type
                door_area += sub_surf.grossArea.to_f
                total_door_area_m2 += sub_surf.grossArea.to_f
              elsif /WINDOW/ =~ subsurf_type
                window_area += sub_surf.grossArea.to_f
                total_window_area_m2 += sub_surf.grossArea.to_f
              elsif /DOME/ =~ subsurf_type
                dome_area += sub_surf.grossArea.to_f
                total_dome_area_m2 += sub_surf.grossArea.to_f
              end
            end
          elsif /FLOOR/ =~ surf_type
            ext_floor_area += surface.grossArea.to_f
          elsif /RoofCeiling/ =~ surf_type
            roof_area += surface.grossArea.to_f
            total_roof_area_m2 += surface.grossArea.to_f
            surface.subSurfaces.sort.each do |sub_surf|
              subsurf_type = sub_surf.subSurfaceType.to_s.upcase
              if /SKYLIGHT/ =~ subsurf_type
                skylight_area += sub_surf.grossArea.to_f
                total_skylight_area_m2 += sub_surf.grossArea.to_f
              elsif /DOME/ =~ subsurf_type
                dome_area += sub_surf.grossArea.to_f
                total_dome_area_m2 += sub_surf.grossArea.to_f
              end
            end
          end
        elsif surface_BC == "GROUND"
          if surf_type == "FLOOOR"
            ground_floor_area += surface.grossArea.to_f
            total_slab_area_m2 += surface.grossArea.to_f
          elsif surf_type == "WALL"
            ground_wall_area += surface.grossArea.to_f
            total_belowwall_area_m2 += surface.grossArea.to_f
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
    srr = 0
    if roof_area > 0
      srr = skylight_area/roof_area
    end
    fdwr = 0
    wwr = 0
    if ext_wallarea > 0
      fdwr = wall_subsurf_area/ext_wallarea
      wwr = window_area/ext_wallarea
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
        (ventilation_air/tz_floor_area),
        tz.multiplier,
        srr,
        fdwr,
        wwr
    ]
    total_out << [
        total_roof_area_m2,
        total_extwall_area_m2,
        total_belowwall_area_m2,
        total_slab_area_m2,
        total_skylight_area_m2,
        total_window_area_m2,
        total_door_area_m2,
        total_dome_area_m2,
        total_subsurface_area_m2
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
        ventilation_air_m3_per_s_per_m2: tz_out[23],
        tz_multiplier: tz_out[24],
        srr: tz_out[25],
        fdwr: tz_out[26],
        wwr: tz_out[26]
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
      total_roof_area_m2: total_door_area_m2,
      total_extwall_area_m2: total_extwall_area_m2,
      total_belowwall_area_m2: total_belowwall_area_m2,
      total_slab_area_m2: total_slab_area_m2,
      total_skylight_area_m2: total_skylight_area_m2,
      total_window_area_m2: total_window_area_m2,
      total_door_area_m2: total_door_area_m2,
      total_dome_area_m2: total_dome_area_m2,
      total_subsurface_area_m2: total_subsurface_area_m2,
      tz_info: tz_json
  }
  airloops_fileout = []
  largest_num_heating_coils = 0
  json_cont["air_loops"].each do |air_loop|
    al_name = air_loop["name"].to_s
    heating_coils = air_loop["heating_coils"]["coil_heating_gas"] unless air_loop["heating_coils"]["coil_heating_gas"].empty?
    heating_coils = air_loop["heating_coils"]["coil_heating_electric"] unless air_loop["heating_coils"]["coil_heating_electric"].empty?
    heating_coils = air_loop["heating_coils"]["coil_heating_water"] unless air_loop["heating_coils"]["coil_heating_water"].empty?
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
        num_heating_coils: heating_coils.size,
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
    largest_num_heating_coils = heating_coils.size if largest_num_heating_coils < heating_coils.size
    airloops_fileout << ind_out
  end
  airloops_out << {
      file_name: json_file,
      building_type: building_name,
      template: template,
      fuel: fuel,
      province: province,
      sheet_name: curr_sheetname,
      largest_num_heating_coils: largest_num_heating_coils,
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
      "Ventilation_Air/Area_m/s",
      "TZ_Multiplier",
      "SRR",
      "FDWR",
      "WWR"
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
building_type_pre = total_out_json.uniq{|ind_res| ind_res[:building_type]}
building_type_pre.each {|building_ind| building_types << building_ind[:building_type]}

# Sort json output by building type, then weather city, then fuel type, and finally vintage
sorted_json = []
building_types.sort.each do |building_type|
  sort_building_type = total_out_json.select{|ind_rec| ind_rec[:building_type] == building_type}
  provinces.sort.each do |prov|
    sort_weather_loc = sort_building_type.select{|ind_rec| ind_rec[:province] == prov}
    fuel_types.sort.each do |fuel_type|
      sort_fuel_types = sort_weather_loc.select{|ind_rec| ind_rec[:fuel] == fuel_type}
      templates.each do |template|
        test_val = sort_fuel_types.select{|ind_rec| ind_rec[:template] == template}[0]
        unless test_val.nil?
          sorted_json << test_val
        end
      end
    end
  end
end

workbook = WriteXLSX.new('./res_out_2020-07-29.xlsx')
sorted_json.each do |json_sort|
  airloop_out = airloops_out.select{|ind_rec| ind_rec[:sheet_name] == json_sort[:sheet_name]}[0]
  #workbook_name = json_sort[:sheet_name] + '.xlsx'
  #workbook = WriteXLSX.new(workbook_name)
  worksheet_name = json_sort[:sheet_name].to_s
  worksheet = workbook.add_worksheet(worksheet_name)
  row = 0
  worksheet.write(row,0, "File Name")
  worksheet.write(row,1, "Worksheet Name")
  row += 1 #row = 1
  worksheet.write(row,0, json_sort[:file_name].to_s)
  worksheet.write(row,1, json_sort[:sheet_name].to_s)
  row += 2 # row = 3
  worksheet.write(row,0, "Building Type")
  worksheet.write(row,1, "Template")
  worksheet.write(row,2, "Predominant Heating Fuel")
  worksheet.write(row,3, "Province")
  row += 1 #row = 4
  worksheet.write(row,0, json_sort[:building_type].to_s)
  worksheet.write(row,1, json_sort[:template].to_s)
  worksheet.write(row,2, json_sort[:fuel].to_s)
  worksheet.write(row,3, json_sort[:province].to_s)
  row += 2 #row = 6
  col_titles = [
      "total_roof_area_m2",
      "total_ext_wall_area_m2",
      "total_below_grade_wall_area_m2",
      "total_slab_area_m2",
      "total_skylight_area_m2",
      "total_window_area_m2",
      "total_door_area_m2",
      "total_dome_area_m2",
      "total_sub_surface_area_m2",
      "total_srr",
      "total_dome_srr",
      "total_fdwr",
      "total_wwr",
  ]
  col = 0
  col_titles.each do |col_title|
    worksheet.write(row, col, col_title)
    col += 1
  end
  row += 1 #row = 7
  worksheet.write(row, 0, json_sort[:total_roof_area_m2].to_f)
  worksheet.write(row, 1, json_sort[:total_extwall_area_m2].to_f)
  worksheet.write(row, 2, json_sort[:total_belowwall_area_m2].to_f)
  worksheet.write(row, 3, json_sort[:total_slab_area_m2].to_f)
  worksheet.write(row, 4, json_sort[:total_skylight_area_m2].to_f)
  worksheet.write(row, 5, json_sort[:total_window_area_m2].to_f)
  worksheet.write(row, 6, json_sort[:total_door_area_m2].to_f)
  worksheet.write(row, 7, json_sort[:total_dome_area_m2].to_f)
  worksheet.write(row, 8, json_sort[:total_subsurface_area_m2].to_f)
  json_sort[:total_roof_area_m2] == 0 ? worksheet_srr = 0 : worksheet_srr = (json_sort[:total_skylight_area_m2].to_f/json_sort[:total_roof_area_m2].to_f)
  json_sort[:total_roof_area_m2] == 0 ? worksheet_srr_dome = 0 : worksheet_srr_dome = (json_sort[:total_skylight_area_m2].to_f+json_sort[:total_dome_area_m2].to_f)/json_sort[:total_roof_area_m2].to_f
  json_sort[:total_extwall_area_m2] == 0 ? worksheet_fdwr = 0 : worksheet_fdwr = (json_sort[:total_subsurface_area_m2].to_f/json_sort[:total_extwall_area_m2].to_f)
  json_sort[:total_extwall_area_m2] == 0 ? worksheet_wwr = 0 : worksheet_wwr = (json_sort[:total_window_area_m2].to_f/json_sort[:total_extwall_area_m2].to_f)
  worksheet.write(row, 9, worksheet_srr) unless worksheet_srr.nil?
  worksheet.write(row, 10, worksheet_srr_dome) unless worksheet_srr_dome.nil?
  worksheet.write(row, 11, worksheet_fdwr) unless worksheet_srr_dome.nil?
  worksheet.write(row, 12, worksheet_wwr) unless worksheet_wwr.nil?

  row += 2 #row = 9

  col_titles = [
      "tz_name",
      "tz_multiplier",
      "floor_area_m2",
      "volume_m3",
      "ext_wall_area_m2",
      "wall_subsurf_area_m2",
      "area_people_m2_per_person",
      "num_people",
      "ventilation_air_L_per_s",
      "light_power_W_per_m2",
      "electric_power_W_per_m2",
      "shw_L_per_hour_per_person",
      "tz_floor_area_m2",
      "exp_floor_area_m2",
      "ground_floor_area_m2",
      "ground_wall_area_m2",
      "door_area_m2",
      "dome_area_m2",
      "skylight_area_m2",
      "roof_area_m2",
      "window_area_m2",
      "light_power_W",
      "electric_power_W",
      "shw_m3_per_s",
      "ventilation_air_m3_per_s_per_m2",
      "srr",
      "fdwr",
      "window_to_wall_ratio"
  ]
  col = 0
  col_titles.each do |col_title|
    worksheet.write(row, col, col_title)
    col += 1
  end
  row += 1 #row = 10
  json_sort[:tz_info].each do |tz_entry|
    worksheet.write(row,0,tz_entry[:tz_name].to_s)
    worksheet.write(row,1,tz_entry[:tz_multiplier].to_f)
    worksheet.write(row,2,tz_entry[:floor_area_m2].to_f)
    worksheet.write(row,3,tz_entry[:volume_m3].to_f)
    worksheet.write(row,4,tz_entry[:ext_wall_area_m2].to_f)
    worksheet.write(row,5,tz_entry[:wall_subsurf_area_m2].to_f)
    worksheet.write(row,6,tz_entry[:area_people_m2_per_person].to_f)
    worksheet.write(row,7,tz_entry[:num_people].to_f)
    worksheet.write(row,8,tz_entry[:ventilation_air_L_per_s].to_f)
    worksheet.write(row,9,tz_entry[:light_power_W_per_m2].to_f)
    worksheet.write(row,10,tz_entry[:electric_power_W_per_m2].to_f)
    worksheet.write(row,11,tz_entry[:shw_L_per_hour_per_person].to_f)
    worksheet.write(row,12,tz_entry[:tz_floor_area_m2].to_f)
    worksheet.write(row,13,tz_entry[:exp_floor_area_m2].to_f)
    worksheet.write(row,14,tz_entry[:ground_floor_area_m2].to_f)
    worksheet.write(row,15,tz_entry[:ground_wall_area_m2].to_f)
    worksheet.write(row,16,tz_entry[:door_area_m2].to_f)
    worksheet.write(row,17,tz_entry[:dome_area_m2].to_f)
    worksheet.write(row,18,tz_entry[:skylight_area_m2].to_f)
    worksheet.write(row,19,tz_entry[:roof_area_m2].to_f)
    worksheet.write(row,20,tz_entry[:window_area_m2].to_f)
    worksheet.write(row,21,tz_entry[:light_power_W].to_f)
    worksheet.write(row,22,tz_entry[:electric_power_W].to_f)
    worksheet.write(row,23,tz_entry[:shw_m3_per_s].to_f)
    worksheet.write(row,24,tz_entry[:ventilation_air_m3_per_s_per_m2].to_f)
    worksheet.write(row,25,tz_entry[:srr].to_f)
    worksheet.write(row,26,tz_entry[:fdwr].to_f)
    worksheet.write(row,27,tz_entry[:wwr].to_f)
    row += 1
  end
  row += 1

  worksheet.write(row,0,"Ventilation AHU")
  row += 2

  worksheet.write(row,0,"File Name")
  worksheet.write(row,1,"Largest Number Heating Coils")
  row += 1
  worksheet.write(row,0,airloop_out[:file_name].to_s)
  worksheet.write(row,1,airloop_out[:largest_num_heating_coils].to_f)

  row +=2

  col_titles = [
      "air_loop_name",
      "system_type",
      "heating_coils",
      "cooling_coils_dx",
      "cooling_coils_water",
      "area_served_m2",
      "outdoor_air_rate_L_per_s",
      "supply_fan_motor_eff",
      "supply_fan_static_pressure_rise_Pa",
      "return_fan_motor_eff",
      "return_fan_static_pressure_rise_Pa",
      "economizer",
      "number_of_heating_coils",
      "supply_fan_total_efficiency",
      "return_fan_total_efficiency"
  ]
  col = 0
  col_after_heat_coils = 0
  col_titles.each do |col_title|
    if col_title == "heating_coils"
      worksheet.write(row, col, col_title)
      col += airloop_out[:lagest_num_heating_coils].to_f
      col_after_heat_coils = col
    else
      worksheet.write(row, col, col_title)
      col += 1
    end
  end

  row += 1

  airloop_out[:airloops].each do |air_loop|
    worksheet.write(row,0,air_loop[:airloop_name].to_s)
    worksheet.write(row,1,air_loop[:type].to_s)
    col = 2
    air_loop[:heating_coil].each do |heat_coil|
      worksheet.write(row,col,heat_coil[:type].to_s)
      col += 1
    end
    col = col_after_heat_coils
    cooling_dx_name = nil
    cooling_dx_cop = nil
    cooling_water_name = nil
    cooling_coils_dx = air_loop[:cooling_coil_dx]
    unless cooling_coils_dx.empty?
      cooling_dx_name = air_loop[:cooling_coil_dx][0]["name"].to_s
      cooling_dx_cop = air_loop[:cooling_coil_dx][0]["cop"].to_f
    end
    unless air_loop[:cooling_coils_water].empty?
      cooling_water_name = air_loop[:cooling_coils_water][0]["name"].to_s
    end
    worksheet.write(row,col,cooling_dx_name) unless cooling_dx_name.nil?
    worksheet.write(row,col+1,cooling_dx_cop) unless cooling_dx_cop.nil?
    worksheet.write(row,col+2,cooling_water_name) unless cooling_water_name.nil?
    worksheet.write(row,col+3,air_loop[:area_served].to_f)
    worksheet.write(row,col+4,air_loop[:outdoor_air].to_f)
    worksheet.write(row,col+5,air_loop[:supply_fan_motor_eff].to_f)
    worksheet.write(row,col+6,air_loop[:supply_fan_prise].to_f)
    worksheet.write(row,col+7,air_loop[:return_fan_motor_eff].to_f)
    worksheet.write(row,col+8,air_loop[:return_fan_prise].to_f)
    worksheet.write(row,col+9,air_loop[:economizer].to_s)
    worksheet.write(row,col+10,air_loop[:num_heating_coils].to_s)
    worksheet.write(row,col+11,air_loop[:supply_fan_eff].to_s)
    worksheet.write(row,col+12,air_loop[:return_fan_eff].to_s)
    row += 1
  end
end
workbook.close