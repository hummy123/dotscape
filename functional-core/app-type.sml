signature APP_TYPE =
sig
  datatype triangle_stage =
    NO_TRIANGLE
  | FIRST of {x1: Real32.real, y1: Real32.real}
  | SECOND of
      {x1: Real32.real, x2: Real32.real, y1: Real32.real, y2: Real32.real}

  type triangle =
    { x1: Real32.real
    , x2: Real32.real
    , x3: Real32.real
    , y1: Real32.real
    , y2: Real32.real
    , y3: Real32.real
    }

  type app_type =
    { triangles: triangle list
    , triangleStage: triangle_stage
    , windowWidth: int
    , windowHeight: int
    , xClickPoints: Real32.real vector
    , yClickPoints: Real32.real vector
    , graphLines: Real32.real vector
    }

  val getInitial: int * int -> app_type

  val genGraphLines: int * int * Real32.real vector * Real32.real vector -> Real32.real vector

  val genClickPoints: int * int -> Real32.real vector

  val withTriangleStage: app_type * triangle_stage -> app_type

  val addTriangleAndResetStage:
    app_type
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    -> app_type

  val withWindowResize: app_type * int * int -> app_type
end

structure AppType :> APP_TYPE =
struct
  type triangle =
    { x1: Real32.real
    , y1: Real32.real
    , x2: Real32.real
    , y2: Real32.real
    , x3: Real32.real
    , y3: Real32.real
    }

  datatype triangle_stage =
    NO_TRIANGLE
  (* 
   * triangle_stage represents a work-in-progress triangle which is not fully completed,
   * because user has to click one (x, y) pair, then a second pair, 
   * and then a third, to draw a complete triangle.
   *
   * There is no THIRD triangle_stage because that represents a complete triangle, 
   * which should be added to the `triangles` list. 
   *)
  | FIRST of {x1: Real32.real, y1: Real32.real}
  | SECOND of
      {x1: Real32.real, y1: Real32.real, x2: Real32.real, y2: Real32.real}

  type app_type =
    { triangles: triangle list
    , triangleStage: triangle_stage
    , windowWidth: int
    , windowHeight: int
    , xClickPoints: Real32.real vector
    , yClickPoints: Real32.real vector
    , graphLines: Real32.real vector
    }

  fun genClickPoints (start, finish) =
    let
      val difference = finish - start
      val increment = Real32.fromInt difference / 40.0
      val start = Real32.fromInt start
    in
      Vector.tabulate (41, fn idx => (Real32.fromInt idx * increment) + start)
    end

  local
    (* This function only produces the desired result 
     * when the window is a square and has the aspect ratio 1:1.
     * This is because the function assumes it can use 
     * the same position coordinates both horizontally and vertically.
     * *)
    fun helpGenGraphLinesSquare (pos: Real32.real, limit, acc) =
      if pos >= limit then
        Vector.concat acc
      else
        let
          val pos2 = pos + 0.05
          val vec = Vector.fromList
            [ (* x = _.1 *) 
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

    fun helpGenGraphLinesHorizontal (pos, xClickPoints, acc, halfWidth, yMin, yMax) =
      if pos = Vector.length xClickPoints then
        acc
      else
        let
          val curX = Vector.sub (xClickPoints, pos)
          val ndc = (curX - halfWidth) / halfWidth
          val vec = 
            if (pos + 1) mod 2 = 0 then
              (* if even (thin lines) *)
              Vector.fromList 
              [
                ndc - 0.001, yMin
              , ndc + 0.001, yMin
              , ndc + 0.001, yMax

              , ndc + 0.001, yMax
              , ndc - 0.001, yMax
              , ndc - 0.001, yMin
              ]
            else
              (* if odd (thick lines) *)
              Vector.fromList 
              [
                ndc - 0.002, yMin
              , ndc + 0.002, yMin
              , ndc + 0.002, yMax

              , ndc + 0.002, yMax
              , ndc - 0.002, yMax
              , ndc - 0.002, yMin
              ]
          val acc = vec:: acc
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
              Vector.fromList 
              [
                xMin, ndc - 0.001
              , xMin, ndc + 0.001
              , xMax, ndc + 0.001

              , xMax, ndc + 0.001
              , xMax, ndc - 0.001
              , xMin, ndc - 0.001 
              ]
            else
              (* if odd (thick lines) *)
              Vector.fromList 
              [
                xMin, ndc - 0.002
              , xMin, ndc + 0.002
              , xMax, ndc + 0.002

              , xMax, ndc + 0.002
              , xMax, ndc - 0.002
              , xMin, ndc - 0.002 
              ]
          val acc = vec:: acc
        in
          helpGenGraphLinesVertical 
            (pos + 1, yClickPoints, acc, halfHeight, xMin, xMax)
        end
  in
    fun genGraphLines (windowWidth, windowHeight, xClickPoints, yClickPoints) =
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
            (0, xClickPoints, [], halfWidth, ~1.0, 1.0)
          val lines = helpGenGraphLinesVertical 
            (0, yClickPoints, lines, halfHeight, start, finish)
        in
          Vector.concat lines
        end
  end

  local
    fun make (windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) =
    let
      val xClickPoints = genClickPoints (wStart, wFinish)
      val yClickPoints = genClickPoints (hStart, hFinish)
    in
      { triangles = []
      , triangleStage = NO_TRIANGLE
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , graphLines = genGraphLines (windowWidth, windowHeight, xClickPoints, yClickPoints)
      }
    end
  in
    fun getInitial (windowWidth, windowHeight) =
      if windowWidth = windowHeight then
        make (windowWidth, windowHeight, 0, windowWidth, 0, windowHeight)
      else if windowWidth > windowHeight then
        let
          val difference = windowWidth - windowHeight
          val wStart = difference div 2
          val wFinish = wStart + windowHeight
        in
          make (windowWidth, windowHeight, wStart, wFinish, 0, windowHeight)
        end
      else
        let
          val difference = windowHeight - windowWidth
          val hStart = difference div 2
          val hFinish = hStart + windowWidth
        in
          make (windowWidth, windowHeight, 0, windowWidth, hStart, hFinish)
        end

    fun withTriangleStage (app: app_type, newTriangleStage: triangle_stage) :
      app_type =
      let
        val
          { triangleStage = _
          , triangles
          , xClickPoints
          , yClickPoints
          , windowWidth
          , windowHeight
          , graphLines
          } = app
      in
        { triangleStage = newTriangleStage
        , triangles = triangles
        , xClickPoints = xClickPoints
        , yClickPoints = yClickPoints
        , windowWidth = windowWidth
        , windowHeight = windowHeight
        , graphLines = graphLines
        }
      end
  end

  fun addTriangleAndResetStage (app: app_type, x1, y1, x2, y2, x3, y3) :
    app_type =
    let
      val
        { triangles
        , triangleStage = _
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , graphLines
        } = app

      val newTriangle = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
      val newTriangles = newTriangle :: triangles
    in
      { triangleStage = NO_TRIANGLE
      , triangles = newTriangles
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      }
    end

  local
    fun make
      ( app: app_type
      , windowWidth
      , windowHeight
      , wStart
      , wFinish
      , hStart
      , hFinish
      ) : app_type =
      let
        val
          { xClickPoints = _
          , yClickPoints = _
          , windowWidth = _
          , windowHeight = _
          , graphLines = _
          , triangles
          , triangleStage
          } = app
        val xClickPoints = genClickPoints (wStart, wFinish)
        val yClickPoints = genClickPoints (hStart, hFinish)
      in
        { xClickPoints = xClickPoints
        , yClickPoints = yClickPoints
        , graphLines = genGraphLines (windowWidth, windowHeight, xClickPoints, yClickPoints)
        , triangles = triangles
        , triangleStage = triangleStage
        , windowWidth = windowWidth
        , windowHeight = windowHeight
        }
      end
  in
    fun withWindowResize (app: app_type, windowWidth, windowHeight) =
      if windowWidth = windowHeight then
        make (app, windowWidth, windowHeight, 0, windowWidth, 0, windowHeight)
      else if windowWidth > windowHeight then
        let
          val difference = windowWidth - windowHeight
          val wStart = difference div 2
          val wFinish = wStart + windowHeight
        in
          make
            (app, windowWidth, windowHeight, wStart, wFinish, 0, windowHeight)
        end
      else
        let
          val difference = windowHeight - windowWidth
          val hStart = difference div 2
          val hFinish = hStart + windowWidth
        in
          make (app, windowWidth, windowHeight, 0, windowWidth, hStart, hFinish)
        end
  end
end
