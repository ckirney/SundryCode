class Delaunay_trig_2d
  # 2018-09-17 Chris Kirney
  # This applies Delaunay triangulation to a surface.  This will return a set of ordered points which define the triangles on the surface.  These triangles can then be used to define subsurfaces or new surfaces.
  # Surfaces and subsurfaces are not returned since they may not be needed nor wanted.
  def self.delaunay_triangulation_2d(surface)
    start_array = surface.vertices
    # First sort the points lexicographically (sort starting with x_values, then by y if two x values are the same).
    new_array = surface.vertices.sort_by { |a| [a.x.to_f, a.y.to_f] }
    tri = []
    i = 0
    tri << [new_array[i], new_array[i+1], new_array[i+2]]
    i = 3
    while cur_point <= last_pnt
      tri << [new_array[i-1], new_array[i], new_array[i+1]]


      tri_start = []
    end
    # Then halve the array until we are left with subarrays with a length of no more than 3.
    array_partitions = []
    array_sz = new_array.length
    array_sz = 43
    local_sz = array_sz
    while local_sz > 3
      local_sz /= 2
      if local_sz <= 3
        array_partitions.push(local_sz)
        local_sz = array_sz - array_partitions.inject(:+)
        if local_sz <= 3
          array_partitions.push(local_sz)
          break
        end
      end
    end
    i = 0
    array_partitions.each do |array_part|
      if array_part = 3
        tri = [new_array[i], new_array[i+1], new_array[i+2]]
        i += array_part - 1
      elsif array_part < 3
        puts "test"
      end
    end
    puts "hello"
  end
end