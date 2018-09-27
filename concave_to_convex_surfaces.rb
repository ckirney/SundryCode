require 'json'
require 'csv'

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
        {x: -1.73853133146172, y: -1.48909706045603},
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
    dx = 4.21
    dy = 1.48
    surface.each do |surf|
      surf[:x] += dx
      surf[:y] += dy
    end
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
              overlap_y = line_segment_overlap_y?(point_a1: surf_verts[i][:y].to_f.round(tol), point_a2: surf_verts[i-1][:y].to_f.round(tol), point_b1: surf_verts[j][:y].to_f.round(tol), point_b2: surf_verts[j-1][:y].to_f.round(tol))
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
    out_json_filea = './overlap_segs_out.json'
    File.open(out_json_filea,"w") {|each_file| each_file.write(JSON.pretty_generate(overlap_segs))}
    out_json_fileb = './in_points.json'
    File.open(out_json_fileb,"w") {|each_file| each_file.write(JSON.pretty_generate(surf_verts))}
    if overlap_segs.length > 1
      overlap_segs = subdivide_overlaps(overlap_segs: overlap_segs)
      out_json_filec = './sub_overlap_segs.json'
      File.open(out_json_filec,"w") {|each_file| each_file.write(JSON.pretty_generate(overlap_segs))}
      for i in 1..(surf_verts.length-1)
        if surf_verts[i][:y].to_f.round(tol) > surf_verts[i-1][:y].to_f.round(tol)
          closest_overlaps = []
          closest_overlaps = get_overlapping_segments(overlap_segs: overlap_segs, index: i, point_a1: surf_verts[i], point_a2: surf_verts[i-1], tol: tol)
          closest_overlaps = closest_overlaps.sort_by {|closest_overlap| [closest_overlap[:overlap_y][:overlap_start]]}
          for j in 0..(closest_overlaps.length - 1)
            new_surf = []
            y_loc = closest_overlaps[j][:overlap_y][:overlap_start]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: surf_verts[closest_overlaps[j][:index_a1]], point_b2: surf_verts[closest_overlaps[j][:index_a2]], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            x_loc = line_segment_overlap_x_coord(y_check: y_loc, point_b1: closest_overlaps[j][:point_b1], point_b2: closest_overlaps[j][:point_b2], tol: tol)
            new_surf << [x: x_loc, y: y_loc]
            y_loc = closest_overlaps[j][:overlap_y][:overlap_end]
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
    out_json_filed = './final_surfs.json'
    File.open(out_json_filed,"w") {|each_file| each_file.write(JSON.pretty_generate(new_surfs))}
    return new_surfs
  end

  def self.get_overlapping_segments(overlap_segs:, index:, point_a1:, point_a2:, tol: 8)
    closest_overlaps = []
    linea_overlaps = []
    for j in 0..(overlap_segs.length-1)
      if (overlap_segs[j][:index_a1] == index) && (overlap_segs[j][:index_a2] == (index - 1))
        linea_x_top = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_start], point_b1: point_a1, point_b2: point_a2, tol: tol)
        linea_x_bottom = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_end], point_b1: point_a1, point_b2: point_a2, tol: tol)
        lineb_x_top = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_start], point_b1: overlap_segs[j][:point_b1], point_b2: overlap_segs[j][:point_b2], tol: tol)
        lineb_x_bottom = line_segment_overlap_x_coord(y_check: overlap_segs[j][:overlap_y][:overlap_end], point_b1: overlap_segs[j][:point_b1], point_b2: overlap_segs[j][:point_b2], tol: tol)
        x_distance_top = linea_x_top - lineb_x_top
        x_distance_bottom = linea_x_bottom - lineb_x_bottom
        linea_overlap = {
            dx_top: x_distance_top,
            dx_bottom: x_distance_bottom,
            overlap: overlap_segs[j]
        }
        linea_overlaps << linea_overlap
      end
    end
    for j in 0..(linea_overlaps.length - 1)
      overlap_found = false
      for k in 0..(linea_overlaps.length - 1)
        if linea_overlaps[j][:overlap] == linea_overlaps[k][:overlap]
          next
        elsif (linea_overlaps[j][:overlap][:overlap_y][:overlap_start] == linea_overlaps[k][:overlap][:overlap_y][:overlap_start]) && (linea_overlaps[j][:overlap][:overlap_y][:overlap_end] == linea_overlaps[k][:overlap][:overlap_y][:overlap_end])
          overlap_found = true
          if (linea_overlaps[j][:dx_top] < linea_overlaps[k][:dx_top]) && (linea_overlaps[j][:dx_bottom] < linea_overlaps[k][:dx_bottom])
            closest_overlaps << linea_overlaps[j][:overlap]
          end
        end
      end
      if overlap_found == false
        closest_overlaps << linea_overlaps[j][:overlap]
      end
    end
    overlap_exts = [closest_overlaps[0]]
    for j in 0..(closest_overlaps.length - 1)
      index = 0
      found = false
      for l in 0..(overlap_exts.length - 1)
        if overlap_exts[l][:index_b1] == closest_overlaps[j][:index_b1] && overlap_exts[l][:index_b2] == closest_overlaps[j][:index_b2]
          index = l
          found = true
          break
        end
      end
      if found == false
        overlap_exts << closest_overlaps[j]
        index = overlap_exts.length - 1
      end
      for k in 0..(closest_overlaps.length - 1)
        if (closest_overlaps[j][:index_b1] == closest_overlaps[k][:index_b1]) && (closest_overlaps[j][:index_b2] == closest_overlaps[k][:index_b2])
          if closest_overlaps[k][:overlap_y][:overlap_start] >= overlap_exts[index][:overlap_y][:overlap_start]
            overlap_exts[index][:overlap_y][:overlap_start] = closest_overlaps[k][:overlap_y][:overlap_start]
          end
          if closest_overlaps[k][:overlap_y][:overlap_end] <= overlap_exts[index][:overlap_y][:overlap_end]
            overlap_exts[index][:overlap_y][:overlap_end] = closest_overlaps[k][:overlap_y][:overlap_end]
          end
        end
      end
    end
    return overlap_exts
  end

  def self.subdivide_overlaps(overlap_segs:)
    restart = true
    while restart == true
      restart = false
      overlap_segs.each do |overlap_seg|
        for j in 0..(overlap_segs.length-1)
          if overlap_seg == overlap_segs[j]
            next
          end
          overlap_segs_overlap = line_segment_overlap_y?(point_a1: overlap_seg[:overlap_y][:overlap_start], point_a2: overlap_seg[:overlap_y][:overlap_end], point_b1: overlap_segs[j][:overlap_y][:overlap_end], point_b2: overlap_segs[j][:overlap_y][:overlap_start])
          unless ((overlap_segs_overlap[:overlap_start].nil?) || (overlap_segs_overlap[:overlap_end].nil?))
            # If the two overlaping segments start and end at the same point then do nothing and go to the next segment.
            if (overlap_seg[:overlap_y][:overlap_start] == overlap_segs[j][:overlap_y][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] == overlap_segs[j][:overlap_y][:overlap_end])
              next
            # If the start point of one overlapping segment shares the end point of the other overlapping segment then
            # they are not really overlapping.  Ignore and go to the next point.
            elsif overlap_segs_overlap[:overlap_start] == overlap_segs_overlap[:overlap_end]
              next
            # If the overlap_seg segment covers beyond the overlap_segs[j] segment then break overlap_seg into three smaller pieces:
            # -One piece for where overlap_seg starts to where overlap_segs[j] starts;
            # -One piece to cover overlap_segs[j] (the middle part); and
            # -One piece for where overlap_segs[j] ends to where overlap_seg ends (the bottom part).
            # The overlap_segs[j] remains as it is associated with another upward pointing line segment.
            # If overlap_seg starts at the same point as overlap_segs[j] or ends at the same point as overlap_segs[j]
            # then overlap_seg is broken into two pieces (no mid piece).
            elsif (overlap_seg[:overlap_y][:overlap_start] >= overlap_segs[j][:overlap_y][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] <= overlap_segs[j][:overlap_y][:overlap_end])
              # If the overlap_seg and overlap_segs[j] start at the same point replace overlap_seg with two segments (
              # one top and one bottom).
              if overlap_seg[:overlap_y][:overlap_start] == overlap_segs[j][:overlap_y][:overlap_start]
                overlap_top = {
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
                overlap_segs << overlap_bottom
              elsif overlap_seg[:overlap_y][:overlap_end] == overlap_segs[j][:overlap_y][:overlap_end]
                # If the overlap_seg and overlap_segs[j] end at the same point replace overlap_seg with two segments (
                # one top and one bottom).
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
                overlap_bottom = {
                    index_a1: overlap_seg[:index_a1],
                    index_a2: overlap_seg[:index_a2],
                    index_b1: overlap_seg[:index_b1],
                    index_b2: overlap_seg[:index_b2],
                    point_b1: overlap_seg[:point_b1],
                    point_b2: overlap_seg[:point_b2],
                    overlap_y: overlap_segs_overlap
                }
                overlap_segs.delete(overlap_seg)
                overlap_segs << overlap_top
                overlap_segs << overlap_bottom
              elsif (overlap_seg[:overlap_y][:overlap_start] > overlap_segs[j][:overlap_y][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] < overlap_segs[j][:overlap_y][:overlap_end])
                # If the overlap_seg stretches above and below overlap_segs[j] then break overlap_seg into three pieces
                # (one top, one middle, one bottom).
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
              end
              restart = true
              break
            # If the overlap_segs[j] segment covers beyond the overlap_seg segment then break overlap_segs[j] into three smaller pieces:
            # -One piece for where overlap_segs[j] starts to where overlap_seg starts;
            # -One piece to cover overlap_seg (the middle part); and
            # -One piece for where overlap_seg ends to where overlap_segs[j] ends (the bottom part).
            # The overlap_seg remains as it is associated with another upward pointing line segment.
            # If overlap_segs[j] starts at the same point as overlap_seg or ends at the same point as overlap_seg
            # then overlap_segs[j] is broken into two pieces (no mid piece).
            elsif overlap_seg[:overlap_y][:overlap_start] <= overlap_segs[j][:overlap_y][:overlap_start] && overlap_seg[:overlap_y][:overlap_end] >= overlap_segs[j][:overlap_y][:overlap_end]
              # If the overlap_seg and overlap_segs[j] start at the same point replace overlap_segs[j] with two segments (
              # one top and one bottom).
              if overlap_seg[:overlap_y][:overlap_start] == overlap_segs[j][:overlap_y][:overlap_start]
                overlap_top = {
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
                overlap_segs << overlap_bottom
              elsif  overlap_seg[:overlap_y][:overlap_end] == overlap_segs[j][:overlap_y][:overlap_end]
                # If the overlap_seg and overlap_segs[j] end at the same point replace overlap_segs[j] with two segments (
                # one top and one bottom).
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
                overlap_bottom = {
                    index_a1: overlap_segs[j][:index_a1],
                    index_a2: overlap_segs[j][:index_a2],
                    index_b1: overlap_segs[j][:index_b1],
                    index_b2: overlap_segs[j][:index_b2],
                    point_b1: overlap_segs[j][:point_b1],
                    point_b2: overlap_segs[j][:point_b2],
                    overlap_y: overlap_segs_overlap
                }
                overlap_segs.delete(overlap_segs[j])
                overlap_segs << overlap_top
                overlap_segs << overlap_bottom
              elsif overlap_seg[:overlap_y][:overlap_start] < overlap_segs[j][:overlap_y][:overlap_start] && overlap_seg[:overlap_y][:overlap_end] > overlap_segs[j][:overlap_y][:overlap_end]
                # If the overlap_segs[j] stretches above and below overlap_seg then break overlap_segs[j] into three pieces
                # (one top, one middle, one bottom).
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
              end
              restart = true
              break
            # if overlap_seg covers the top of overlap_segs[j] then break overlap_seg into a top and an overlap portion
            # ond break overlap_segs[j] into an overlap portion and a bottom portion.
            elsif (overlap_seg[:overlap_y][:overlap_start] >= overlap_segs[j][:overlap_y][:overlap_start]) && (overlap_seg[:overlap_end] <= overlap_segs[j][:overlap_start]) && (overlap_seg[:overlap_y][:overlap_end] > overlap_segs[j][:overlap_y][:overlap_end])
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
              restart = true
              break
            elsif (overlap_seg[:overlap_y][:overlap_start] >= overlap_segs[j][:overlap_y][:overlap_end]) && (overlap_seg[:overlap_end] < overlap_segs[j][:overlap_end]) && (overlap_seg[:overlap_y][:overlap_start] <= overlap_segs[j][:overlap_y][:overlap_start])
              # if overlap_seg covers the bottom of overlap_segs[j] then break overlap_segs[j] into a top and an overlap portion
              # ond break overlap_seg into an overlap portion and a bottom portion.
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
              restart = true
              break
            end
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
    if (point_a1 >= point_b1) && (point_a2 <= point_b1)
      overlap_start = point_a1
      overlap_end = point_b1
      if point_a1 >= point_b2
        overlap_start = point_b2
      end
    elsif (point_a1 >= point_b2) && (point_a2 <= point_b2)
      overlap_start = point_b2
      overlap_end = point_a2
      if point_a2 <= point_b1
        overlap_end = point_b1
      end
    elsif (point_a1 <= point_b2) && (point_a2 >= point_b1)
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
      if point_a2 < point_b1
        overlap_end = point_b1
      end
    end
    if (point_a1 <= point_b2) && (point_a2 >= point_b1)
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
    if point_b1[:x].to_f.round(tol) == point_b2[:x].to_f.round(tol)
      xcross = point_b2[:x].to_f.round(tol)
    else
      db_y = (point_b1[:y].to_f.round(tol) - point_b2[:y].to_f.round(tol))
      b1_x = point_b1[:x].to_f.round(tol)
      b2_x = point_b2[:x].to_f.round(tol)
      db_x = b1_x - b2_x
      a = (point_b1[:y].to_f.round(tol) - point_b2[:y].to_f.round(tol))/(point_b1[:x].to_f.round(tol) - point_b2[:x].to_f.round(tol))
      b = point_b1[:y].to_f.round(tol) - a*point_b1[:x]
      xcross = (y_check - b)/a
    end
    return xcross
  end

  self.get_guaranteed_concave_surfaces(1)
end