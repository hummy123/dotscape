structure TriangleStage =
struct
  open AppType

  fun firstToVector (x1, y1, drawVec, model) =
    let
      val windowWidth = #windowWidth model
      val windowHeight = #windowHeight model

      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)

      val x1px = Ndc.centreAlignX (x1, windowWidth, windowHeight, halfWidth)
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = Ndc.centreAlignY (y1, windowWidth, windowHeight, halfHeight)
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = Ndc.ltrbToVertexRgb
        (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, drawVec]
    end

  fun secondToVector (x1, y1, x2, y2, drawVec, model) =
    let
      val windowWidth = #windowWidth model
      val windowHeight = #windowHeight model

      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)

      val x1px = Ndc.centreAlignX (x1, windowWidth, windowHeight, halfWidth)
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = Ndc.centreAlignY (y1, windowWidth, windowHeight, halfHeight)
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = Ndc.ltrbToVertexRgb
        (left, top, right, bottom, 0.0, 0.0, 1.0)

      val x2px = Ndc.centreAlignX (x2, windowWidth, windowHeight, halfWidth)
      val left = (x2px - 5.0) / halfWidth
      val right = (x2px + 5.0) / halfWidth

      val y2px = Ndc.centreAlignY (y2, windowWidth, windowHeight, halfHeight)
      val top = (y2px + 5.0) / halfHeight
      val bottom = (y2px - 5.0) / halfHeight

      val secVec = Ndc.ltrbToVertexRgb (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, secVec, drawVec]
    end

  fun toVector (model: app_type, drawVec) =
    case #triangleStage model of
      NO_TRIANGLE => drawVec
    | FIRST {x1, y1} => firstToVector (x1, y1, drawVec, model)
    | SECOND {x1, y1, x2, y2} => secondToVector (x1, y1, x2, y2, drawVec, model)
end
