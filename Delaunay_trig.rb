class Delaunay_trig_2d
  # 2018-09-17 Chris Kirney
  # This applies Delaunay triangulation to a surface.  This will return a set of ordered points which define the triangles on the surface.  These triangles can then be used to define subsurfaces or new surfaces.
  # Surfaces and subsurfaces are not returned since they may not be needed nor wanted.
#  def delaunay_triangulation_2d()
    data_points = [[0, 0], [0, 0.11], [0, 0.34], [0, 0.53], [0.09, 0.34], [0.13, 0.07], [0.18, 0.4], [0.25, 0], [0.25, 0.17], [0.25, 0.26], [0.34, 0.17], [0.36, 0.28], [0.36, 0.53], [0.4, 0.07], [0.46, 0.41], [0.47, 0], [0.51, 0.17], [0.63, 0], [0.63, 0.22], [0.78, 0.17], [0.79, 0.39], [0.89, 0], [0.89, 0.29], [1.13, 0], [1.13, 0.29], [1.5, 0]]
    start_array = data_points
    # First sort the points lexicographically (sort starting with x_values, then by y if two x values are the same).
    new_array = start_array.sort_by { |a| [a.x.to_f, a.y.to_f] }
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
#  end
end