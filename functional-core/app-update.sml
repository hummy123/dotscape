structure AppUpdate =
struct
  open AppType

  local
    fun helpGetTrianglesVector (lst, acc) =
      case lst of
        {x1, y1, x2, y2, x3, y3} :: tl =>
          let val vec = #[x1, y1, x2, y2, x3, y3]
          in helpGetTrianglesVector (tl, vec :: acc)
          end
      | [] => acc
  in
    fun getTrianglesVector (app: app_type) =
      let val lst = helpGetTrianglesVector (#triangles app, [])
      in Vector.concat lst
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
    fun getVerticalClickPos
      (clickPoints, idx, horizontalPos, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curVerticalPos = Vector.sub (clickPoints, idx)
        in
          if mouseY < curVerticalPos - 7.0 orelse mouseY > curVerticalPos + 7.0 then
            getVerticalClickPos
              (clickPoints, idx + 1, horizontalPos, mouseX, mouseY, r, g, b)
          else
            let
              val halfWidth = Real32.fromInt (Constants.windowWidth div 2)
              val halfHeight = Real32.fromInt (Constants.windowHeight div 2)
              val hpos = horizontalPos - halfWidth
              val vpos = ~(curVerticalPos - halfHeight)
              val left = (hpos - 5.0) / halfWidth
              val right = (hpos + 5.0) / halfWidth
              val bottom = (vpos - 5.0) / halfHeight
              val top = (vpos + 5.0) / halfHeight

              val drawVec = ltrbToVertex (left, top, right, bottom, r, g, b)

              val hpos = hpos / halfWidth
              val vpos = vpos / halfHeight
            in
              (drawVec, hpos, vpos)
            end
        end

    fun getHorizontalClickPos (clickPoints, idx, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curPos = Vector.sub (clickPoints, idx)
        in
          if mouseX < curPos - 7.0 orelse mouseX > curPos + 7.0 then
            getHorizontalClickPos
              (clickPoints, idx + 1, mouseX, mouseY, r, g, b)
          else
            getVerticalClickPos
              (clickPoints, 0, curPos, mouseX, mouseY, r, g, b)
        end
  in
    (*
     * This function returns a vector containing the position data of the
     * clicked square.
     * If a square wasn't found at the clicked position, 
     * an empty vector is returned.
     *)
    fun getClickPos (clickPoints, mouseX, mouseY, r, g, b) =
      getHorizontalClickPos (clickPoints, 0, mouseX, mouseY, r, g, b)
  end

  fun getFirstTriangleStageVector (x1, y1, drawVec) =
    let
      val halfWidth = Real32.fromInt (Constants.windowWidth div 2)
      val halfHeight = Real32.fromInt (Constants.windowHeight div 2)

      val x1px = x1 * halfWidth
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = y1 * halfHeight
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, drawVec]
    end

  fun getSecondTriangleStageVector (x1, y1, x2, y2, drawVec) =
    let
      val halfWidth = Real32.fromInt (Constants.windowWidth div 2)
      val halfHeight = Real32.fromInt (Constants.windowHeight div 2)

      val x1px = x1 * halfWidth
      val left = (x1px - 5.0) / halfWidth
      val right = (x1px + 5.0) / halfWidth

      val y1px = y1 * halfHeight
      val top = (y1px + 5.0) / halfHeight
      val bottom = (y1px - 5.0) / halfHeight

      val firstVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)

      val x2px = x2 * halfWidth
      val left = (x2px - 5.0) / halfWidth
      val right = (x2px + 5.0) / halfWidth

      val y2px = y2 * halfHeight
      val top = (y2px + 5.0) / halfHeight
      val bottom = (y2px - 5.0) / halfHeight

      val secVec = ltrbToVertex (left, top, right, bottom, 0.0, 0.0, 1.0)
    in
      Vector.concat [firstVec, secVec, drawVec]
    end

  fun getTriangleStageVector (model: app_type, drawVec) =
    case #triangleStage model of
      NO_TRIANGLE => drawVec
    | FIRST {x1, y1} => getFirstTriangleStageVector (x1, y1, drawVec)
    | SECOND {x1, y1, x2, y2} =>
        getSecondTriangleStageVector (x1, y1, x2, y2, drawVec)

  local
    open DrawMessage
    open InputMessage

    fun mouseMoveOrRelease (model, mouseX, mouseY) =
      let
        val (drawVec, _, _) = getClickPos
          (#clickPoints model, mouseX, mouseY, 1.0, 0.0, 0.0)
        val drawVec = getTriangleStageVector (model, drawVec)
        val drawMsg = DRAW_BUTTON drawVec
      in
        (model, drawMsg, mouseX, mouseY)
      end

    fun mouseLeftClick (model, mouseX, mouseY) =
      let
        val (buttonVec, hpos, vpos) = getClickPos
          (#clickPoints model, mouseX, mouseY, 0.0, 0.0, 1.0)
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
                val drawVec = getFirstTriangleStageVector (x1, y1, buttonVec)
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
        val low = Int.min (width, height)
        val high = Int.min (width, height)

        val difference = high - low
        val offset = difference div 2
        val _ = print "resized window \n"
      in
        (model, NO_DRAW, mouseX, mouseY)
      end
  in
    fun update (model, mouseX, mouseY, inputMsg) =
      case inputMsg of
        MOUSE_MOVE {x = mouseX, y = mouseY} =>
          mouseMoveOrRelease (model, mouseX, mouseY)
      | MOUSE_LEFT_RELEASE => mouseMoveOrRelease (model, mouseX, mouseY)
      | MOUSE_LEFT_CLICK => mouseLeftClick (model, mouseX, mouseY)
      | RESIZE_WINDOW {width, height} =>
          resizeWindow (model, mouseX, mouseY, width, height)
  end
end
