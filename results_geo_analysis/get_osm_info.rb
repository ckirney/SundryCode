require 'openstudio-standards'
require '/usr/local/openstudio-3.0.1/Ruby/openstudio'
require 'fileutils'
require 'json'
require 'csv'

cost_files = Dir['/home/osdev/SundryCode/results_geo_analysis/results_files/**/*.osm']
total_out = []
cost_files.each do |cost_file|
  #json_cont = JSON.parse(File.read(cost_file.to_s))
  model = BTAP::FileIO.load_osm(cost_file)
  total_out << cost_file.to_s
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
    total_out << tz_out
  end
end
CSV.open('./results_tz_geo.csv', "w") do |csv|
  csv << [
      "Thermal_Zone_Name",
      "Exterior_Wall_Area",
      "Floor_Area",
      "TZ_Floor_Area",
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

