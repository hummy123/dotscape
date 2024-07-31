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

  local
    fun genClickPoints (windowWidth, windowHeight) =
      let
        val w = Real32.fromInt windowWidth / 40.0
        val h = Real32.fromInt windowHeight / 40.0
      in
        Vector.tabulate (41, fn idx => Real32.fromInt idx * w)
      end

    val clickPoints = 
      genClickPoints (Constants.windowWidth, Constants.windowHeight)

    fun getVerticalClickPos (idx, horizontalPos, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curVerticalPos = Vector.sub (clickPoints, idx)
        in
          if mouseY < curVerticalPos - 7.0 orelse mouseY > curVerticalPos + 7.0 then
            getVerticalClickPos
              (idx + 1, horizontalPos, mouseX, mouseY, r, g, b)
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

              val drawVec =
                #[ left, bottom, r, g, b
                 , right, bottom, r, g, b
                 , left, top, r, g, b

                 , left, top, r, g, b
                 , right, bottom, r, g, b
                 , right, top, r, g, b
                 ]

              val hpos = hpos / halfWidth
              val vpos = vpos / halfHeight
            in
              (drawVec, hpos, vpos)
            end
        end

    fun getHorizontalClickPos (idx, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        (#[], 0.0, 0.0)
      else
        let
          val curPos = Vector.sub (clickPoints, idx)
        in
          if mouseX < curPos - 7.0 orelse mouseX > curPos + 7.0 then
            getHorizontalClickPos (idx + 1, mouseX, mouseY, r, g, b)
          else
            getVerticalClickPos (0, curPos, mouseX, mouseY, r, g, b)
        end
  in
    (*
     * This function returns a vector containing the position data of the
     * clicked square.
     * If a square wasn't found at the clicked position, 
     * an empty vector is returned.
     *)
    fun getClickPos (mouseX, mouseY, r, g, b) =
      getHorizontalClickPos
        (0, Real32.fromInt mouseX, Real32.fromInt mouseY, r, g, b)
  end

  fun update (model, mouseX, mouseY, inputMsg) =
    let
      open DrawMessage
      open InputMessage
    in
      case inputMsg of
        MOUSE_MOVE {x = mouseX, y = mouseY} =>
          let
            val (drawVec, _, _) = getClickPos (mouseX, mouseY, 1.0, 0.0, 0.0)
            val drawMsg = DRAW_BUTTON drawVec
          in
            (model, drawMsg, mouseX, mouseY)
          end
      | MOUSE_LEFT_RELEASE =>
          let
            val (drawVec, _, _) = getClickPos (mouseX, mouseY, 1.0, 0.0, 0.0)
            val drawMsg = DRAW_BUTTON drawVec
          in
            (model, drawMsg, mouseX, mouseY)
          end
      | MUSE_LEFT_CLICK =>
          let
            val (buttonVec, hpos, vpos) = 
              getClickPos (mouseX, mouseY, 0.0, 0.0, 1.0)
          in
            if Vector.length buttonVec > 0 then
              let
                val drawMsg = DRAW_BUTTON buttonVec
              in
                (model, drawMsg, mouseX, mouseY)
              end
            else
              (model, NO_DRAW, mouseX, mouseY)
          end
    end
end
