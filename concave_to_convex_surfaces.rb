class Concave_to_convex_surfaces
      # 2018-09-17 Chris Kirney
      # This applies Delaunay triangulation to a surface.  This will return a set of ordered points which define the triangles on the surface.  These triangles can then be used to define subsurfaces or new surfaces.
      # Surfaces and subsurfaces are not returned since they may not be needed nor wanted.

  def self.get_guaranteed_concave_surfaces(surface)
    # Note that points on surfaces are given counterclockwise when looking at the surface from the opposite direction as
    # the outward normal (i.e. the outward normal is pointing at you).  I use point_a1, point_a2, point_b1 and point b2
    # lots.  For this, point_a refers to vectors pointing up.  In this case point_a1 is at the top of the vector and
    # point_a2 is at the bottom of the vector.  Contrarily, point_b refers to vectors pointing down.  In this case
    # point_b1 is at the bottom of the vector and point_b2 is at the top.  All of this comes about because I cycle
    # through the points starting at the 2nd point and and going to the last point.  I count vectors as starting from
    # the last point and going toward the current point.
    # See following where P1 through P4 are the points.  When cycling through a is where you start and b is where you
    # end.  the o is the tip of the outward normal pointing at you.
    #    P2b------------aP1
    #     a              b
    #     |              |
    #     |      o       |
    #     |              |
    #     b              a
    #     P3a-----------bP4
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
    overlap_segs = []
    new_surfs = []
    for i in 1..(surf_verts.length-1)
      # Is this line segment pointing up?  If no, then ignore it and go to the next line segment.
      if surf_verts[i][:y].to_f.round(tol) > surf_verts[i-1][:y].to_f.round(tol)
      # Go through each line segment
        for j in 1..(surf_verts.length-1)
        # Is the line segment to the left of the current (index i) line segment?  If no, then ignore it and go to the next one.
          if surf_verts[j][:x].to_f.round(tol) < surf_verts[i][:x].to_f.round(tol) and surf_verts[j-1][:x].to_f.round(tol) < surf_verts[i-1][:x].to_f.round(tol)
          # Is the line segment pointing down?  If no, then ignore it and go to the next line segment.
            if surf_verts[j][:y].to_f.round(tol) < surf_verts[j-1][:y].to_f.round(tol)
            # Do the y coordinates of the line segment overlap with the current (index i) line segment?  If no
            # then ignore it and go to the next line segment.
              overlap_y = line_segment_overlap_eq_y?(point_a1: surf_verts[i][:y].to_f.round(tol), point_a2: surf_verts[i-1][:y].to_f.round(tol), point_b1: surf_verts[j][:y].to_f.round(tol), point_b2: surf_verts[j-1][:y].to_f.round(tol))
              unless (overlap_y[:overlap_start].nil? || overlap_y[:overlap_end].nil?)
                overlap_seg = {
                    index_a1: i,
                    index_a2: i-1,
                    index_b1: j,
                    index_b2: j-1,
                    point_b1: surf_verts[j],
                    point_b2: surf_verts[j-1],
                    overlap_y: overlap_y
                }
                overlap_segs << overlap_seg
              end
            end
          end
        end
      end
    end
    if overlap_segs.length > 1
      overlap_segs = subdivide_overlaps(overlap_segs: overlap_segs)
      for i in 1..(surf_verts.length-1)
        if surf_verts[i][:y].to_f.round(tol) > surf_verts[i-1][:y].to_f.round(tol)
          closest_overlaps = get_overlapping_segments(overlap_segs: overlap_segs, index: i, tol: tol)
          closest_overlaps = closest_overlaps.sort_by {|closest_overlap| [closest_overlap[:overlap_y][:overlap_start]]}
          for j in 1..(closest_overlaps.length - 1)
            y_loc = closest_overlaps[:overlap_y][:overlap_start]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: surf_verts[closest_overlaps[j][:index_a1]], point_b2: surf_verts[closest_overlaps[j][:index_a2]], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: closest_overlaps[j][:point_b1], point_b2: closest_overlaps[j][:point_b2], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            y_loc = closest_overlaps[:overlap_y][:overlap_end]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: closest_overlaps[j][:point_b1], point_b2: closest_overlaps[j][:point_b2], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: surf_verts[closest_overlaps[j][:index_a1]], point_b2: surf_verts[closest_overlaps[j][:index_a2]], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            new_surfs << new_surf
          end
        end
      end
    elsif overlap_segs.length == 1
      y_loc = closest_overlaps[:overlap_y][:overlap_start]
      x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: surf_verts[closest_overlaps[j][:index_a1]], point_b2: surf_verts[closest_overlaps[j][:index_a2]], tol: tol)
      new_surf << [x: x_loc, y: y_loc]
      x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: closest_overlaps[j][:point_b1], point_b2: closest_overlaps[j][:point_b2], tol: tol)
      new_surf << [x: x_loc, y: y_loc]
      y_loc = closest_overlaps[:overlap_y][:overlap_end]
      x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: closest_overlaps[j][:point_b1], point_b2: closest_overlaps[j][:point_b2], tol: tol)
      new_surf << [x: x_loc, y: y_loc]
      x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: surf_verts[closest_overlaps[j][:index_a1]], point_b2: surf_verts[closest_overlaps[j][:index_a2]], tol: tol)
      new_surf << [x: x_loc, y: y_loc]
      new_surfs << new_surf
    end
    return new_surfs
  end

  def self.get_overlapping_segments(overlap_segs:, index:, tol: 8)
    closest_overlaps = []
    for j in 1..(overlap_segs.length-1)
      if overlap_segs[j][:index_a1] == index
        closest_overlap = overlap_segs[j]
        for k in 1..(overlap_segs.length-1)
          next if j == k
          if overlap_segs[j][:overlap_y][:overlap_start] == overlap_segs[k][:overlap_y][:overlap_start]
            closest_overlap = []
            upline_x_coord = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_start], point_b1: surf_verts[i], point_b2: surf_verts[i-1], tol: tol)
            overlap_line1_x_coord = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_start], point_b1: overlap_segs[j][:point_b1], point_b2: overlap_segs[j][:point_b2], tol: tol)
            overlap_line2_x_coord = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_start], point_b1: overlap_segs[k][:point_b1], point_b2: overlap_segs[k][:point_b2], tol: tol)
            if (upline_x_coord - overlap_line1_x_coord) <= (upline_x_coord - overlap_line2_x_coord)
              closest_overlap = overlap_segs[j]
            elsif (upline_x_coord - overlap_line1_x_coord) > (upline_x_coord - overlap_line2_x_coord)
              closest_overlap = overlap_segs[k]
            end
            closest_overlaps << closest_overlap
          end
        end
        if closest_overlap == overlap_segs[j]
          closest_overlaps << closest_overlap
        end
      end
    end
    return closest_overlaps
  end

  def self.subdivide_overlaps(overlap_segs:)
    restart = false
    while restart == false
      restart == false
      overlap_segs.each do |overlap_seg|
        for j in 1..(overlap_segs.length-1)
          if overlap_seg == overlap_segs[j]
            next
          end
          overlap_segs_overlap = line_segment_overlap_y?(point_a1: overlap_seg[:overlap_y][:overlap_start], point_a2: overlap_seg[:overlap_y][:overlap_end], point_b1: overlap_segs[j][:overlap_y][:overlap_end], point_b2: overlap_segs[j][:overlap_y][:overlap_end])
          unless ((overlap_segs_overlap[:overlap_start].nil?) || (overlap_segs_overlap[:overlap_end].nil?))
            if (overlap_seg[:overlap_y][:overlap_start] > overlap_segs[j][:overlapy_y][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] < overlap_segs[j][:overlap_y][:overlap_end])
              overlap_top_over = {
                  overlap_start: overlap_seg[:overlap_y][:overlap_start],
                  overlap_end: overlap_segs_overlap[:overlap_start]
              }
              overlap_top = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_top_over
              }
              overlap_mid = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_bottom_over = {
                  overlap_start: overlap_segs_overlap[:overlap_end],
                  overlap_end: overlap_seg[:overlap_y][:overlap_end]
              }
              overlap_bottom = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_bottom_over
              }
              overlap_segs.delete(overlap_seg)
              overlap_segs << overlap_top
              overlap_segs << overlap_mid
              overlap_segs << overlap_bottom
            elsif overlap_seg[:overlap_y][:overlap_start] < overlap_segs[j][:overlap_y][:overlap_start] && overlap_seg[:overlap_y][:overlap_end] > overlap_segs[j][:overlap_y][:overlap_end]
              overlap_top_over = {
                  overlap_start: overlap_segs[j][:overlap_y][:overlap_start],
                  overlap_end: overlap_segs_overlap[:overlap_start]
              }
              overlap_top = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_top_over
              }
              overlap_mid = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_bottom_over = {
                  overlap_start: overlap_segs_overlap[:overlap_end],
                  overlap_end: overlap_segs[j][:overlap_y][:overlap_end]
              }
              overlap_bottom = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_bottom_over
              }
              overlap_segs.delete(overlap_segs[j])
              overlap_segs << overlap_top
              overlap_segs << overlap_mid
              overlap_segs << overlap_bottom
            elsif (overlap_seg[:overlap_y][:overlap_start] > overlap_segs[j][:overlap_y][:overlap_start]) && (overlap_seg[:overlap_end] < overlap_segs[j][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] > overlap_segs[j][:overlap_y][:overlap_end])
              overlap_top_over = {
                  overlap_start: overlap_seg[:overlap_y][:overlap_start],
                  overlap_end: overlap_segs_overlap[:overlap_start]
              }
              overlap_top = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_top_over
              }
              overlap_mid_seg = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_mid_segs = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_bottom_over = {
                  overlap_start: overlap_segs_overlap[:overlap_end],
                  overlap_end: overlap_segs[j][:overlap_y][:overlap_end]
              }
              overlap_bottom = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_bottom_over
              }
              overlap_segs.delete(overlap_seg)
              overlap_segs.delete(overlap_segs[j])
              overlap_segs << overlap_top
              overlap_segs << overlap_mid_seg
              overlap_segs << overlap_mid_segs
              overlap_segs << overlap_bottom
            elsif (overlap_seg[:overlap_y][:overlap_start] > overlap_segs[j][:overlap_y][:overlap_end]) && (overlap_seg[:overlap_end] < overlap_segs[j][:overlap_end]) && (overlap_seg[:overlap_y][:overlap_start] < overlap_segs[j][:overlap_y][:overlap_start])
              overlap_top_over = {
                  overlap_start: overlap_segs[j][:overlap_y][:overlap_start],
                  overlap_end: overlap_segs_overlap[:overlap_start]
              }
              overlap_top = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_top_over
              }
              overlap_mid_seg = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_mid_segs = {
                  index_a1: overlap_segs[j][:index_a1],
                  index_a2: overlap_segs[j][:index_a2],
                  index_b1: overlap_segs[j][:index_b1],
                  index_b2: overlap_segs[j][:index_b2],
                  point_b1: overlap_segs[j][:point_b1],
                  point_b2: overlap_segs[j][:point_b2],
                  overlap_y: overlap_segs_overlap
              }
              overlap_bottom_over = {
                  overlap_start: overlap_segs_overlap[:overlap_end],
                  overlap_end: overlap_seg[:overlap_y][:overlap_end]
              }
              overlap_bottom = {
                  index_a1: overlap_seg[:index_a1],
                  index_a2: overlap_seg[:index_a2],
                  index_b1: overlap_seg[:index_b1],
                  index_b2: overlap_seg[:index_b2],
                  point_b1: overlap_seg[:point_b1],
                  point_b2: overlap_seg[:point_b2],
                  overlap_y: overlap_bottom_over
              }
              overlap_segs.delete(overlap_seg)
              overlap_segs.delete(overlap_seg[j])
              overlap_segs << overlap_top
              overlap_segs << overlap_mid_seg
              overlap_segs << overlap_mid_segs
              overlap_segs << overlap_bottom
            end
            restart = true
            break
          end
        end
        if restart == true
          break
        end
      end
    end
    return overlap_segs
  end

  def self.line_segment_overlap_y?(point_a1:, point_a2:, point_b1:, point_b2:)
    overlap_start = nil
    overlap_end = nil
    if (point_a1 > point_b1) && (point_a2 < point_b1)
      overlap_start = point_a1
      overlap_end = point_b1
      if point_a1 > point_b2
        overlap_start = point_b2
      end
    end
    if (point_a1 > point_b2) && (point_a2 < point_b2)
      overlap_start = point_b2
      overlap_end = point_a2
      if point_a2 < point_b1
        overlap_end = point_b1
      end
    end
    if (point_a1 < point_b2) && (point_a2 > point_b1)
      overlap_start = point_a1
      overlap_end = point_a2
    end
    # Overlap vectors always point down.  Thus overlap_start is the y location of the top of the overlap vector and
    # overlap_end is the y location of the bottom of the overlap vector.  The overlap vector will later be constructed
    # using point_b1 and point_b2 and checking which overlaps are closest (and not obstructed) by other overlaps.
    overlap_y = {
        overlap_start: overlap_start,
        overlap_end: overlap_end
    }
    return overlap_y
  end

  def self.line_segment_overlap_eq_y?(point_a1:, point_a2:, point_b1:, point_b2:)
    overlap_start = nil
    overlap_end = nil
    if (point_a1 > point_b1) && (point_a2 < point_b1)
      overlap_start = point_a1
      overlap_end = point_b1
      if point_a1 > point_b2
        overlap_start = point_b2
      end
    end
    if (point_a1 > point_b2) && (point_a2 < point_b2)
      overlap_start = point_b2
      overlap_end = point_a2
      if point_a2 < point_b1
        overlap_end = point_b1
      end
    end
    if (point_a1 < point_b2) && (point_a2 > point_b1)
      overlap_start = point_a1
      overlap_end = point_a2
    end
    # Overlap vectors always point down.  Thus overlap_start is the y location of the top of the overlap vector and
    # overlap_end is the y location of the bottom of the overlap vector.  The overlap vector will later be constructed
    # using point_b1 and point_b2 and checking which overlaps are closest (and not obstructed) by other overlaps.
    overlap_y = {
        overlap_start: overlap_start,
        overlap_end: overlap_end
    }
    return overlap_y
  end

  def self.line_segment_overlap_x_coord(y_check:, point_b1:, point_b2:, tol: 8)
    a = (point_b1[:y].to_f.round(tol) - point_b2[:y].to_f.round(tol))/(point_b1[:x].to_f.round(tol) - point_b2[:x].to_f.round(tol))
    b = point_b1[:y].to_f.round(tol) - a*point_b1[:x]
    xcross = (y_check - b)/a
    return xcross
  end

  self.get_guaranteed_concave_surfaces(1)
end