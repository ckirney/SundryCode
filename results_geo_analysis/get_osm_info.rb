require 'openstudio-standards'
require '/usr/local/openstudio-3.0.1/Ruby/openstudio'
require 'fileutils'
require 'json'

cost_files = Dir['/home/osdev/cost_results/**/*.osm']
cost_files.each do |cost_file|
  #json_cont = JSON.parse(File.read(cost_file.to_s))
  model = BTAP::FileIO.load_osm(cost_file)
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
    tz.spaces.sort.each do |space|

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
    end
  end
end

