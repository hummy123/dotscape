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

  fun ltrbToVertex (left, top, right, bottom, r, g, b) =
    #[ left, bottom, r, g, b
     , right, bottom, r, g, b
     , left, top, r, g, b

     , left, top, r, g, b
     , right, bottom, r, g, b
     , right, top, r, g, b
     ]

  local
    (*
     * Range to detect from clickable position. 
     * For example, if we have a clickable position at (x, y) = (500, 500),
     * with a range of 15, we can detect clicks targeting this position 
     * from top left at (485, 485) to bottom right at (515, 515).
     * *)
    val range = 15.0

    fun getVerticalClickPos
      ( yClickPoints
      , idx
      , horizontalPos
      , mouseX
      , mouseY
      , r
      , g
      , b
      , windowWidth
      , windowHeight
      ) =
      if idx = Vector.length yClickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curVerticalPos = Vector.sub (yClickPoints, idx)
        in
          if mouseY < curVerticalPos - range orelse mouseY > curVerticalPos + range then
            getVerticalClickPos
              ( yClickPoints
              , idx + 1
              , horizontalPos
              , mouseX
              , mouseY
              , r
              , g
              , b
              , windowWidth
              , windowHeight
              )
          else
            let
              (* calculate normalised device coordinates *)
              val halfWidth = Real32.fromInt (windowWidth div 2)
              val halfHeight = Real32.fromInt (windowHeight div 2)
              val hpos = horizontalPos - halfWidth
              val vpos = ~(curVerticalPos - halfHeight)

              (* coordinates to form small box around clicked area *)
              val left = (hpos - 5.0) / halfWidth
              val right = (hpos + 5.0) / halfWidth
              val bottom = (vpos - 5.0) / halfHeight
              val top = (vpos + 5.0) / halfHeight

              (* normalised device coordinates of drawVec should be relative
               * to actual windowWidth and windowHeight,
               * even if not a square, to display cursor position... *)
              val drawVec = ltrbToVertex (left, top, right, bottom, r, g, b)
            in
              (* 
               * ...however, normalised device coordinate of hpos and vpos 
               * should be relative to the vertical centre 
               * (if height is greater than width)
               * or horizontal centre 
               * (if width is greater than height).
               *
               * So, for example, a 900x1000 resolution 
               * will have clickable points from 50...950,
               * in increments of 50.
               * Because we always want to show canvas as a square
               * with an aspect ratio of 1:1.
               * For displaying the click position on the screen, drawVec
               * which uses actual windowWidth and windowHeight, is fine.
               * However, we want to attach the meaning "start" to 50
               * and "end" to 950,
               * so the hpos and vpos stored in the app's triangle list
               * subtracts the offset 50 if needed,
               * allowing us to treat the coordinates as a 900x900 square.
               *
               * We may not actually want to render a square to the screen 
               * if the screen's aspect ratio is not 1:1,
               * but it's the responsibility of the rendering code
               * which turns triangles into OpenGL vectors
               * to do that.
               * *)
              if windowWidth = windowHeight then
                let
                  val hpos = hpos / halfWidth
                  val vpos = vpos / halfHeight
                in
                  (drawVec, hpos, vpos)
                end
              else if windowWidth > windowHeight then
                let
                  val difference = windowWidth - windowHeight
                  val offset = Real32.fromInt (difference div 2)
                  val hpos = hpos / (halfWidth - offset)
                  val vpos = vpos / halfHeight
                in
                  (drawVec, hpos, vpos)
                end
              else
                (* windowHeight > windowWidth *)
                let
                  val difference = windowHeight - windowWidth
                  val offset = Real32.fromInt (difference div 2)
                  val hpos = hpos / halfWidth
                  val vpos = vpos / (halfHeight - offset)
                in
                  (drawVec, hpos, vpos)
                end
            end
        end

    fun getHorizontalClickPos
      ( xClickPoints
      , yClickPoints
      , idx
      , mouseX
      , mouseY
      , r
      , g
      , b
      , windowWidth
      , windowHeight
      ) =
      if idx = Vector.length xClickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curPos = Vector.sub (xClickPoints, idx)
        in
          if mouseX < curPos - range orelse mouseX > curPos + range then
            getHorizontalClickPos
              ( xClickPoints
              , yClickPoints
              , idx + 1
              , mouseX
              , mouseY
              , r
              , g
              , b
              , windowWidth
              , windowHeight
              )
          else
            getVerticalClickPos
              ( yClickPoints
              , 0
              , curPos
              , mouseX
              , mouseY
              , r
              , g
              , b
              , windowWidth
              , windowHeight
              )
        end
  in
    (*
     * This function returns a vector containing the position data of the
     * clicked square.
     * If a square wasn't found at the clicked position, 
     * an empty vector is returned.
     *)
    fun getClickPos (mouseX, mouseY, r, g, b, model: app_type) =
      getHorizontalClickPos
        ( #xClickPoints model
        , #yClickPoints model
        , 0
        , mouseX
        , mouseY
        , r
        , g
        , b
        , #windowWidth model
        , #windowHeight model
        )
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
