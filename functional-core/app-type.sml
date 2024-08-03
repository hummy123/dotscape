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

  val genGraphLines: int * int -> Real32.real vector

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

    fun helpGenGraphLinesVertical (pos, limit, acc, xMin, xMax) =
      if pos <= limit + 0.01 then
        let
          val vec = Vector.fromList
            [ (* y = _.1 *) 
              xMin, pos - 0.002
            , xMin, pos + 0.002
            , xMax, pos + 0.002

            , xMax, pos + 0.002
            , xMax, pos - 0.002
            , xMin, pos - 0.002 
            ]
          val acc = vec :: acc
          val pos = pos + 0.05
        in
          if pos <= limit + 0.01 then
            let
              val vec = Vector.fromList 
                [ (* y = _.05 *)
                  xMin, pos - 0.001
                , xMin, pos + 0.001
                , xMax, pos + 0.001

                , xMax, pos + 0.001
                , xMax, pos - 0.001
                , xMin, pos - 0.001
                ]
              val acc = vec :: acc
              val pos = pos + 0.05
            in
              helpGenGraphLinesVertical (pos, limit, acc, xMin, xMax)
            end
          else
            acc
        end
      else
        acc

    fun helpGenGraphLinesHorizontal (pos, limit, acc, yMin, yMax) =
      if pos <= limit + 0.01 then
        let
          val pos2 = pos + 0.05
          val vec = Vector.fromList
            [ (* x = _.1 *) 
              pos - 0.002, yMin
            , pos + 0.002, yMin
            , pos + 0.002, yMax

            , pos + 0.002, yMax
            , pos - 0.002, yMax
            , pos - 0.002, yMin
            ]
          val acc = vec :: acc
          val pos = pos + 0.05
        in
          if pos <= limit + 0.01 then
            let
              val vec = Vector.fromList 
                [
                  (* x = _.05 *)
                  pos2 - 0.001, yMin
                , pos2 + 0.001, yMin
                , pos2 + 0.001, yMax

                , pos2 + 0.001, yMax
                , pos2 - 0.001, yMax
                , pos2 - 0.001, yMin
                ]
              val acc = vec :: acc
              val pos = pos + 0.05
            in
              helpGenGraphLinesHorizontal (pos, limit, acc, yMin, yMax)
            end
          else
            acc
        end
      else
        acc
  in
    fun genGraphLines (windowWidth, windowHeight) =
      if windowWidth = windowHeight then
        helpGenGraphLinesSquare (~1.0, 1.0, [])
      else if windowWidth > windowHeight then
        let
          val difference = windowWidth - windowHeight
          val offset = difference div 2

          val halfWidth = Real32.fromInt (windowWidth div 2)
          val start = offset - (windowWidth div 2)
          val start = Real32.fromInt start / halfWidth

          val finish = (windowWidth - offset) - (windowWidth div 2)
          val finish = Real32.fromInt finish / halfWidth

          val lines = helpGenGraphLinesHorizontal (start, finish, [], ~1.0, 1.0)
          val lines = helpGenGraphLinesVertical (~1.0, 1.0, lines, start, finish)
        in
          Vector.concat lines
        end
      else
        (* windowWidth < windowHeight *)
        let
          val difference = windowHeight - windowWidth
          val offset = difference div 2
          val offset = Real32.fromInt (difference - (windowWidth div 2))
          val ndcOffset = offset / Real32.fromInt windowWidth
          val start = ndcOffset
          val finish = 
            if ndcOffset > 0.0 then
              1.0 - ndcOffset
            else
              1.0 + ndcOffset

          val lines = helpGenGraphLinesHorizontal (~1.0, 1.0, [], start, finish)
          val lines = helpGenGraphLinesVertical (start, finish, lines, ~1.0, 1.0)
        in
          Vector.concat lines
        end
  end

  local
    fun make (windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) =
      { triangles = []
      , triangleStage = NO_TRIANGLE
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , xClickPoints = genClickPoints (wStart, wFinish)
      , yClickPoints = genClickPoints (hStart, hFinish)
      , graphLines = genGraphLines (windowWidth, windowHeight)
      }
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
          val hFinish = hStart + windowHeight
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
      in
        { xClickPoints = genClickPoints (wStart, wFinish)
        , yClickPoints = genClickPoints (hStart, hFinish)
        , graphLines = genGraphLines (windowWidth, windowHeight)
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
          val hFinish = hStart + windowHeight
        in
          make (app, windowWidth, windowHeight, 0, windowWidth, hStart, hFinish)
        end
  end
end
