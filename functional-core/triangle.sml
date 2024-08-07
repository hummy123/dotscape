structure Triangle =
struct
  open AppType

  local
    fun helpToVector
      (lst, acc, windowWidth, windowHeight, halfWidth, halfHeight) =
      case lst of
        {x1, y1, x2, y2, x3, y3} :: tl =>
          let
            val x1 = Ndc.centreAlignX (x1, windowWidth, windowHeight, halfWidth)
            val x2 = Ndc.centreAlignX (x2, windowWidth, windowHeight, halfWidth)
            val x3 = Ndc.centreAlignX (x3, windowWidth, windowHeight, halfWidth)

            val y1 = Ndc.centreAlignY (y1, windowWidth, windowHeight, halfHeight)
            val y2 = Ndc.centreAlignY (y2, windowWidth, windowHeight, halfHeight)
            val y3 = Ndc.centreAlignY (y3, windowWidth, windowHeight, halfHeight)

            val vec =
             #[ x1 / halfWidth
              , y1 / halfHeight
              , x2 / halfWidth
              , y2 / halfHeight
              , x3 / halfWidth
              , y3 / halfHeight
              ]
            val acc = vec :: acc
          in
            helpToVector
              (tl, acc, windowWidth, windowHeight, halfWidth, halfHeight)
          end
      | [] => acc
  in
    fun toVector (app: app_type) =
      let
        val windowWidth = #windowWidth app
        val windowHeight = #windowHeight app
        val halfWidth = Real32.fromInt (windowWidth div 2)
        val halfHeight = Real32.fromInt (windowHeight div 2)
        val lst = helpToVector
          (#triangles app, [], windowWidth, windowHeight, halfWidth, halfHeight)
      in
        Vector.concat lst
      end
  end
end
