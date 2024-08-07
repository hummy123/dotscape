structure Ndc = 
struct
  (* ndc = normalised device coordinates *)

  fun ltrbToVertex (left, top, right, bottom, r, g, b) =
    #[ left, bottom, r, g, b
     , right, bottom, r, g, b
     , left, top, r, g, b

     , left, top, r, g, b
     , right, bottom, r, g, b
     , right, top, r, g, b
     ]

  (* This function adjusts the x position to be centre-aligned to the grid
   * if windowWidth is greater than height 
   * (where screen size does not have 1:1 aspect ratio). *)
  fun centreAlignX (x, windowWidth, windowHeight, halfWidth) =
    if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val offset = Real32.fromInt (difference div 2)
      in
        x * (halfWidth - offset)
      end
    else
      x * halfWidth

  (* Similar to centreAlignX, except it centre-aligns the y-point
   * when windowHeight is greater than windowWidth. *)
  fun centreAlignY (y, windowWidth, windowHeight, halfHeight) =
    if windowHeight > windowWidth then
      let
        val difference = windowHeight - windowWidth
        val offset = Real32.fromInt (difference div 2)
      in
        y * (halfHeight - offset)
      end
    else
      y * halfHeight
end
