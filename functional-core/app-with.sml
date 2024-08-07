structure AppWith =
struct
  open AppType

  fun triangleStage (app: app_type, newTriangleStage: triangle_stage) : app_type =
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

  fun newTriangle (app: app_type, x1, y1, x2, y2, x3, y3) : app_type =
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
        val xClickPoints = ClickPoints.generate (wStart, wFinish)
        val yClickPoints = ClickPoints.generate (hStart, hFinish)
        val graphLines =
          GraphLines.generate
            (windowWidth, windowHeight, xClickPoints, yClickPoints)
      in
        { xClickPoints = xClickPoints
        , yClickPoints = yClickPoints
        , graphLines = graphLines
        , triangles = triangles
        , triangleStage = triangleStage
        , windowWidth = windowWidth
        , windowHeight = windowHeight
        }
      end
  in
    fun windowResize (app: app_type, windowWidth, windowHeight) =
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
