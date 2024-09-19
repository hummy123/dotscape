signature CLICK_POINTS =
sig
  val generate: int * int -> Real32.real vector
  val getClickPositionFromMouse: AppType.app_type
                                 -> (Real32.real * Real32.real) option
  val getDrawDot:
    Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * AppType.app_type
    -> Real32.real vector

  (* two below functions convert pixel coordinates to normalised device coordinates *)
  val xposToNdc: Real32.real * int * int * Real32.real -> Real32.real
  val yposToNdc: Real32.real * int * int * Real32.real -> Real32.real
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

  fun getClickPos (clickPoints, mousePos, idx) =
    if idx = Vector.length clickPoints then
      NONE
    else
      let
        val curPos = Vector.sub (clickPoints, idx)
      in
        if mousePos < curPos - range orelse mousePos > curPos + range then
          getClickPos (clickPoints, mousePos, idx + 1)
        else
          SOME (Vector.sub (clickPoints, idx))
      end

  fun getClickPositionFromMouse (app: AppType.app_type) =
    case getClickPos (#xClickPoints app, #mouseX app, 0) of
      SOME xPos =>
        (case getClickPos (#yClickPoints app, #mouseY app, 0) of
           SOME yPos => SOME (xPos, yPos)
         | NONE => NONE)
    | NONE => NONE

  fun getDrawDot (xpos, ypos, r, g, b, app: AppType.app_type) =
    let
      val {windowWidth, windowHeight, ...} = app

      (* calculate normalised device coordinates *)
      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)
      val hpos = xpos - halfWidth
      val vpos = ~(ypos - halfHeight)

      (* coordinates to form small box around clicked area *)
      val left = (hpos - 5.0) / halfWidth
      val right = (hpos + 5.0) / halfWidth
      val bottom = (vpos - 5.0) / halfHeight
      val top = (vpos + 5.0) / halfHeight
    in
      Ndc.ltrbToVertex (left, top, right, bottom, r, g, b)
    end

  fun xposToNdc (xpos, windowWidth, windowHeight, halfWidth) =

    let
      val xpos = xpos - halfWidth

    in
      if windowWidth > windowHeight then
        let
          val difference = windowWidth - windowHeight
          val offset = Real32.fromInt (difference div 2)
        in
          xpos / (halfWidth - offset)
        end
      else
        xpos / halfWidth

    end

  fun yposToNdc (ypos, windowWidth, windowHeight, halfHeight) =
    let
      val ypos = ~(ypos - halfHeight)
    in
      if windowHeight > windowWidth then
        let
          val difference = windowHeight - windowWidth
          val offset = Real32.fromInt (difference div 2)
        in
          ypos / (halfHeight - offset)
        end
      else
        ypos / halfHeight
    end
end
