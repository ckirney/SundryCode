class Concave_to_convex_surfaces
      # 2018-09-17 Chris Kirney
      # This applies Delaunay triangulation to a surface.  This will return a set of ordered points which define the triangles on the surface.  These triangles can then be used to define subsurfaces or new surfaces.
      # Surfaces and subsurfaces are not returned since they may not be needed nor wanted.

  def self.get_guaranteed_concave_surfaces(surface)
    surface = [
        {X: -1.73853133146172, y: -1.48909706045603},
        {x: -1.23930351151008, y: -0.929390366029091},
        {x: 0.190696488489919, y: -0.929390366029091},
        {x: 0.485628533085157, y: -1.21419747456199},
        {x: 2.02562853308516, y: -1.21419747456199},
        {x: 2.02562853308516, y: 0.714575767260116},
        {x: 1.31562853308516, y: 0.714575767260116},
        {x: 0, y: 0},
        {x: -3.2, y: 0},
        {x: -2.82320764267297, y: 0.134266598452254},
        {x: -2.59360460421024, y: 0.42440870971617},
        {x: -3.00137189571629, y: 0.747094061069194},
        {x: -3.62784683185621, y: 0.954769659993287},
        {x: -3.91784683185621, y: 0.954769659993287},
        {x: -4.12443745118676, y: 0.853674081432116},
        {x: -4.21443745118676, y: 0.853674081432116},
        {x: -4.21443745118676, y: -0.446325918567885},
        {x: -3.10853133146172, y: -1.48909706045603}
    ]
    tol = 8
    surf_verts = surface
    for i in 1..(surf_verts.length-1)
      # Is this line segment pointing up?  If no, then ignore it and go to the next line segment.
      if surf_verts[i][:y].to_f.round(tol) > surf_verts[i-1][:y].to_f.round(tol)
      # Go through each line segment
        overlap_seg = []
        for j in 1..(surf_verts.length-1)
        # Is the line segment to the left of the current (index i) line segment?  If no, then ignore it and go to the next one.
          if surf_verts[j][:x].to_f.round(tol) < surf_verts[i][:x].to_f.round(tol) and surf_verts[j-1][:x].to_f.round(tol) < surf_verts[i-1][:x].to_f.round(tol)
          # Is the line segment pointing down?  If no, then ignore it and go to the next line segment.
            if surf_verts[j][:y].to_f.round(tol) < surf_verts[j-1][:y].to_f.round(tol)
            # Do the y coordinates of the line segment overlap with the current (index i) line segment?  If no
            # then ignore it and go to the next line segment.
              overlap_y = line_segment_overlap_y?(surf_verts[i][:y].to_f.round(tol), surf_verts[i-1][:y].to_f.round(tol), surf_verts[j][:y].to_f.round(tol), surf_verts[j-1][:y].to_f.round(tol))
              unless (overlap_y[:overlap_start].nil? || overlap_y[:overlap_end].nil?)
                overlap_seg << [surf_verts[j][:y].to_f.round(tol), surf_verts[j-1][:y].to_f.round(tol)]
              end
            end
          end
        end
        if overlap_seg.length > 0
          puts "hello"
        end
      end
    end
  end

  def self.line_segment_overlap_y?(point_a1, point_a2, point_b1, point_b2)
    overlap_start = nil
    overlap_end = nil
    if (point_a1 >= point_b1) && (point_a2 <= point_b1)
      overlap_start = point_a1
      overlap_end = point_b1
      if point_a1 > point_b2
        overlap_start = point_b2
      end
    end
    if (point_a1 >= point_b2) && (point_a2 <= point_b2)
      overlap_start = point_b2
      overlap_end = point_a2
      if point_a2 <= point_b1
        overlap_end = point_b1
      end
    end
    if (point_a1 <= point_b2) && (point_a2 >= point_b1)
      overlap_start = point_a1
      overlap_end = point_a2
    end
    overlap_y = {
        overlap_start: overlap_start,
        overlap_end: overlap_end
    }
    return overlap_y
  end

  def self.line_segment_overlap_x_coord(point_a:, point_b1:, point_b2:, tol: 8)
    a = (point_b1[:y].to_f.round(tol) - point_b2[:y].to_f.round(tol))/(point_b1[:x].to_f.round(tol) - point_b2[:x].to_f.round(tol))
    b = point_b1[:y].to_f.round(tol) - a*point_b1[:x]
    xcross = (point_a - b)/a
    return xcross
  end

  self.get_guaranteed_concave_surfaces(1)
end