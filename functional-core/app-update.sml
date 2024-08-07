structure AppUpdate =
struct
  open AppType

  (* This function adjusts the x position to be centre-aligned to the grid
   * if windowWidth is greater than height 
   * (where screen size does not have 1:1 aspect ratio). *)
  fun calcRelativeX (x, windowWidth, windowHeight, halfWidth) =
    if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val offset = Real32.fromInt (difference div 2)
      in
        x * (halfWidth - offset)
      end
    else
      x * halfWidth

  (* Similar to calcRelativeX, except it centre-aligns the y-point
   * when windowHeight is greater than windowWidth. *)
  fun calcRelativeY (y, windowWidth, windowHeight, halfHeight) =
    if windowHeight > windowWidth then
      let
        val difference = windowHeight - windowWidth
        val offset = Real32.fromInt (difference div 2)
      in
        y * (halfHeight - offset)
      end
    else
      y * halfHeight

  local
    fun helpGetTrianglesVector
      (lst, acc, windowWidth, windowHeight, halfWidth, halfHeight) =
      case lst of
        {x1, y1, x2, y2, x3, y3} :: tl =>
          let
            val x1 = calcRelativeX (x1, windowWidth, windowHeight, halfWidth)
            val x2 = calcRelativeX (x2, windowWidth, windowHeight, halfWidth)
            val x3 = calcRelativeX (x3, windowWidth, windowHeight, halfWidth)

            val y1 = calcRelativeY (y1, windowWidth, windowHeight, halfHeight)
            val y2 = calcRelativeY (y2, windowWidth, windowHeight, halfHeight)
            val y3 = calcRelativeY (y3, windowWidth, windowHeight, halfHeight)

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
            helpGetTrianglesVector
              (tl, acc, windowWidth, windowHeight, halfWidth, halfHeight)
          end
      | [] => acc
  in
    fun getTrianglesVector (app: app_type) =
      let
        val windowWidth = #windowWidth app
        val windowHeight = #windowHeight app
        val halfWidth = Real32.fromInt (windowWidth div 2)
        val halfHeight = Real32.fromInt (windowHeight div 2)
        val lst = helpGetTrianglesVector
          (#triangles app, [], windowWidth, windowHeight, halfWidth, halfHeight)
      in
        Vector.concat lst
      end
  end


  fun getFirstTriangleStageVector (x1, y1, drawVec, model) =
    let
      val windowWidth = #windowWidth model
      val windowHeight = #windowHeight model

      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)

      val x1px = calcRelativeX (x1, windowWidth, windowHeight, halfWidth)
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = calcRelativeY (y1, windowWidth, windowHeight, halfHeight)
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, drawVec]
    end

  fun getSecondTriangleStageVector (x1, y1, x2, y2, drawVec, model) =
    let
      val windowWidth = #windowWidth model
      val windowHeight = #windowHeight model

      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)


      val x1px = calcRelativeX (x1, windowWidth, windowHeight, halfWidth)
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = calcRelativeY (y1, windowWidth, windowHeight, halfHeight)
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)

      val x2px = calcRelativeX (x2, windowWidth, windowHeight, halfWidth)
      val left = (x2px - 5.0) / halfWidth
      val right = (x2px + 5.0) / halfWidth

      val y2px = calcRelativeY (y2, windowWidth, windowHeight, halfHeight)
      val top = (y2px + 5.0) / halfHeight
      val bottom = (y2px - 5.0) / halfHeight

      val secVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, secVec, drawVec]
    end

  fun getTriangleStageVector (model: app_type, drawVec) =
    case #triangleStage model of
      NO_TRIANGLE => drawVec
    | FIRST {x1, y1} => getFirstTriangleStageVector (x1, y1, drawVec, model)
    | SECOND {x1, y1, x2, y2} =>
        getSecondTriangleStageVector (x1, y1, x2, y2, drawVec, model)

  local
    open DrawMessage
    open InputMessage

    fun mouseMoveOrRelease (model: app_type, mouseX, mouseY) =
      let
        val {xClickPoints, yClickPoints, ...} = model
        val (drawVec, _, _) = getClickPos (mouseX, mouseY, 1.0, 0.0, 0.0, model)
        val drawVec = getTriangleStageVector (model, drawVec)
        val drawMsg = DRAW_BUTTON drawVec
      in
        (model, drawMsg, mouseX, mouseY)
      end

    fun mouseLeftClick (model: app_type, mouseX, mouseY) =
      let
        val {xClickPoints, yClickPoints, ...} = model
        val (buttonVec, hpos, vpos) = getClickPos
          (mouseX, mouseY, 0.0, 0.0, 1.0, model)
      in
        if Vector.length buttonVec > 0 then
          case #triangleStage model of
            NO_TRIANGLE =>
              let
                val drawVec = getTriangleStageVector (model, buttonVec)
                val drawMsg = DRAW_BUTTON drawVec

                val newTriangleStage = FIRST {x1 = hpos, y1 = vpos}
                val model = AppType.withTriangleStage (model, newTriangleStage)
              in
                (model, drawMsg, mouseX, mouseY)
              end
          | FIRST {x1, y1} =>
              let
                val drawVec =
                  getFirstTriangleStageVector (x1, y1, buttonVec, model)
                val drawMsg = DRAW_BUTTON drawVec

                val newTriangleStage = SECOND
                  {x1 = x1, y1 = y1, x2 = hpos, y2 = vpos}
                val model = AppType.withTriangleStage (model, newTriangleStage)
              in
                (model, drawMsg, mouseX, mouseY)
              end
          | SECOND {x1, y1, x2, y2} =>
              let
                val model = AppType.addTriangleAndResetStage
                  (model, x1, y1, x2, y2, hpos, vpos)

                val drawVec = getTrianglesVector model
                val drawMsg = DRAW_TRIANGLES_AND_RESET_BUTTONS drawVec
              in
                (model, drawMsg, mouseX, mouseY)
              end
        else
          (model, NO_DRAW, mouseX, mouseY)
      end

    fun resizeWindow (model, mouseX, mouseY, width, height) =
      let
        val model = AppType.withWindowResize (model, width, height)

        val triangles = getTrianglesVector model
        val graphLines = #graphLines model
        val drawMsg = 
          RESIZE_TRIANGLES_BUTTONS_AND_GRAPH 
            {triangles = triangles,
            graphLines = graphLines}
      in
        (model, drawMsg, mouseX, mouseY)
      end
  in
    fun update (model: app_type, mouseX, mouseY, inputMsg) =
      case inputMsg of
        MOUSE_MOVE {x = mouseX, y = mouseY} =>
          mouseMoveOrRelease (model, mouseX, mouseY)
      | MOUSE_LEFT_RELEASE => mouseMoveOrRelease (model, mouseX, mouseY)
      | MOUSE_LEFT_CLICK => mouseLeftClick (model, mouseX, mouseY)
      | RESIZE_WINDOW {width, height} =>
          resizeWindow (model, mouseX, mouseY, width, height)
  end
end
