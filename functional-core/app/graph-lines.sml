signature GRAPH_LINES =
sig
  val generate: AppType.app_type -> Real32.real vector
end

structure GraphLines :> GRAPH_LINES =
struct

  (* this function generates graph lines which look like:
   * . . .
   * . . .
   * . . .
   * where the dots signify click points.
   *
   * I think this is not as useful for plotting points as the other method,
   * where that other method is similar to graph paper,
   * but there might be a run-time option to change to the grid genereated by this function
   * in the future. *)
  fun generateUnconnectedGrid (app: AppType.app_type) =
    let
      val {windowWidth, windowHeight, xClickPoints, yClickPoints, ...} = app
    in
      Vector.concat (List.tabulate (Vector.length xClickPoints, fn xIdx =>
        let
          val xpos = Vector.sub (xClickPoints, xIdx)
        in
          Vector.concat (List.tabulate (Vector.length yClickPoints, fn yIdx =>
            ClickPoints.getDrawDot
              (xpos, Vector.sub (yClickPoints, yIdx), windowWidth, windowHeight)))
        end))
    end

      (* 
   * This function only produces the desired result 
   * when the window is a square and has the aspect ratio 1:1.
   * This is because the function assumes it can use 
   * the same position coordinates both horizontally and vertically.
   *)
  fun helpGenGraphLinesSquare (pos: Real32.real, limit, acc) =
    if pos >= limit then
      Vector.concat acc
    else
      let
        val pos2 = pos + 0.05
        val vec = 
          #[ (* x = _.1 *) 
             pos - 0.002, ~1.0
           , pos + 0.002, ~1.0
           , pos + 0.002, 1.0

           , pos + 0.002, 1.0
           , pos - 0.002, 1.0
           , pos - 0.002, ~1.0

             (* y = _.1 *)
           , ~1.0, pos - 0.002
           , ~1.0, pos + 0.002
           , 1.0, pos + 0.002

           , 1.0, pos + 0.002
           , 1.0, pos - 0.002
           , ~1.0, pos - 0.002 

              (* x = _.05 *)
           , pos2 - 0.001, ~1.0
           , pos2 + 0.001, ~1.0
           , pos2 + 0.001, 1.0

           , pos2 + 0.001, 1.0
           , pos2 - 0.001, 1.0
           , pos2 - 0.001, ~1.0

             (* y = _.05 *)
           , ~1.0, pos2 - 0.001
           , ~1.0, pos2 + 0.001
           , 1.0, pos2 + 0.001

           , 1.0, pos2 + 0.001
           , 1.0, pos2 - 0.001
           , ~1.0, pos2 - 0.001
           ]
        val acc = vec :: acc
        val nextPos = pos + 0.1
      in
        helpGenGraphLinesSquare (nextPos, limit, acc)
      end

  fun helpGenGraphLinesHorizontal
    (pos, xClickPoints, acc, halfWidth, yMin, yMax) =
    if pos = Vector.length xClickPoints then
      acc
    else
      let
        val curX = Vector.sub (xClickPoints, pos)
        val ndc = (curX - halfWidth) / halfWidth
        val vec =
          if (pos + 1) mod 2 = 0 then 
            (* if even (thin lines) *) 
           #[
              ndc - 0.001, yMin
            , ndc + 0.001, yMin
            , ndc + 0.001, yMax

            , ndc + 0.001, yMax
            , ndc - 0.001, yMax
            , ndc - 0.001, yMin
            ]
          else 
            (* if odd (thick lines) *) 
            #[
               ndc - 0.002, yMin
             , ndc + 0.002, yMin
             , ndc + 0.002, yMax

             , ndc + 0.002, yMax
             , ndc - 0.002, yMax
             , ndc - 0.002, yMin
             ]
        val acc = vec :: acc
      in
        helpGenGraphLinesHorizontal
          (pos + 1, xClickPoints, acc, halfWidth, yMin, yMax)
      end

  fun helpGenGraphLinesVertical (pos, yClickPoints, acc, halfHeight, xMin, xMax) =
    if pos = Vector.length yClickPoints then
      acc
    else
      let
        val curY = Vector.sub (yClickPoints, pos)
        val ndc = (curY - halfHeight) / halfHeight
        val vec =
          if (pos + 1) mod 2 = 0 then 
            (* if even (thin lines) *) 
            #[
               xMin, ndc - 0.001
             , xMin, ndc + 0.001
             , xMax, ndc + 0.001

             , xMax, ndc + 0.001
             , xMax, ndc - 0.001
             , xMin, ndc - 0.001 
             ]
          else 
            (* if odd (thick lines) *) 
            #[
               xMin, ndc - 0.002
             , xMin, ndc + 0.002
             , xMax, ndc + 0.002

             , xMax, ndc + 0.002
             , xMax, ndc - 0.002
             , xMin, ndc - 0.002 
             ]
        val acc = vec :: acc
      in
        helpGenGraphLinesVertical
          (pos + 1, yClickPoints, acc, halfHeight, xMin, xMax)
      end

  fun helpGenerate (windowWidth, windowHeight, xClickPoints, yClickPoints) =
    if windowWidth = windowHeight then
      helpGenGraphLinesSquare (~1.0, 1.0, [])
    else if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val offset = difference div 2

        val halfWidth = Real32.fromInt (windowWidth div 2)
        val halfHeight = Real32.fromInt (windowHeight div 2)

        val start = offset - (windowWidth div 2)
        val start = Real32.fromInt start / halfWidth

        val finish = (windowWidth - offset) - (windowWidth div 2)
        val finish = Real32.fromInt finish / halfWidth

        val lines = helpGenGraphLinesHorizontal
          (0, xClickPoints, [], halfWidth, ~1.0, 1.0)
        val lines = helpGenGraphLinesVertical
          (0, yClickPoints, lines, halfHeight, start, finish)
      in
        Vector.concat lines
      end
    else
      (* windowWidth < windowHeight *)
      let
        val difference = windowHeight - windowWidth
        val offset = difference div 2

        val halfWidth = Real32.fromInt (windowWidth div 2)
        val halfHeight = Real32.fromInt (windowHeight div 2)

        val start = offset - (windowHeight div 2)
        val start = Real32.fromInt start / halfHeight

        val finish = (windowHeight - offset) - (windowHeight div 2)
        val finish = Real32.fromInt finish / halfHeight

        val lines = helpGenGraphLinesHorizontal
          (0, xClickPoints, [], halfWidth, start, finish)
        val lines = helpGenGraphLinesVertical
          (0, yClickPoints, lines, halfHeight, ~1.0, 1.0)
      in
        Vector.concat lines
      end

  fun generate (app: AppType.app_type) = 
    let
      val {windowWidth, windowHeight, xClickPoints, yClickPoints, ...} = app
    in
      helpGenerate (windowWidth, windowHeight, xClickPoints, yClickPoints)
    end
end
