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
    }

  val getInitial: int * int -> app_type

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
    fun make (windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) =
      { triangles = []
      , triangleStage = NO_TRIANGLE
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , xClickPoints = genClickPoints (wStart, wFinish)
      , yClickPoints = genClickPoints (hStart, hFinish)
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
          make (windowWidth, windowHeight, 0, wFinish, 0, windowHeight)
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
          } = app
      in
        { triangleStage = newTriangleStage
        , triangles = triangles
        , xClickPoints = xClickPoints
        , yClickPoints = yClickPoints
        , windowWidth = windowWidth
        , windowHeight = windowHeight
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
          , triangles
          , triangleStage
          , windowWidth
          , windowHeight
          } = app

        val xClickPoints = genClickPoints (wStart, wFinish)
        val yClickPoints = genClickPoints (hStart, hFinish)
      in
        { xClickPoints = xClickPoints
        , yClickPoints = yClickPoints
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
