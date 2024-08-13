signature CLICK_POINTS =
sig
  val generate: int * int -> Real32.real vector
  val getClickPosition:
    Real32.real * Real32.real * Real32.real * AppType.app_type
    -> Real32.real vector * Real32.real * Real32.real
end

structure ClickPoints :> CLICK_POINTS =
struct
  fun generate (start, finish) =
    let
      val difference = finish - start
      val increment = Real32.fromInt difference / 40.0
      val start = Real32.fromInt start
    in
      Vector.tabulate (41, fn idx => (Real32.fromInt idx * increment) + start)
    end

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
        if
          mouseY < curVerticalPos - range orelse mouseY > curVerticalPos + range
        then
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
            val drawVec = Ndc.ltrbToVertex (left, top, right, bottom, r, g, b)
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

  (*
   * This function returns a vector containing the position data of the
   * clicked square.
   * If a square wasn't found at the clicked position, 
   * an empty vector is returned.
   *)
  fun getClickPosition (r, g, b, app: AppType.app_type) =
    let
      val
        { xClickPoints
        , yClickPoints
        , mouseX
        , mouseY
        , windowWidth
        , windowHeight
        , ...
        } = app
    in
      getHorizontalClickPos
        ( xClickPoints
        , yClickPoints
        , 0
        , mouseX
        , mouseY
        , r
        , g
        , b
        , windowWidth
        , windowHeight
        )
    end
end
