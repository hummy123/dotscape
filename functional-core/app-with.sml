signature APP_WITH =
sig
  val windowResize: AppType.app_type * int * int -> AppType.app_type

  val newTriangleStage:
    AppType.app_type * AppType.triangle_stage * (Real32.real * Real32.real)
    -> AppType.app_type
  val replaceTriangleStage: AppType.app_type * AppType.triangle_stage
                            -> AppType.app_type

  val undoTriangle:
    AppType.app_type * AppType.triangle_stage * AppType.triangle list
    -> AppType.app_type

  val newTriangle:
    AppType.app_type
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * (Real32.real * Real32.real)
    -> AppType.app_type

  val mousePosition: AppType.app_type * Real32.real * Real32.real
                     -> AppType.app_type
end

structure AppWith :> APP_WITH =
struct
  open AppType

  fun newTriangleStage
    (app: app_type, newTriangleStage: triangle_stage, xyTuple) : app_type =
    let
      val
        { triangleStage = _
        , triangles
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , graphLines
        , undo
        , mouseX
        , mouseY
        } = app

      val newUndo = xyTuple :: undo
    in
      { triangleStage = newTriangleStage
      , triangles = triangles
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      , undo = newUndo
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun replaceTriangleStage (app: app_type, newTriangleStage) =
    let
      val
        { triangleStage = _
        , triangles
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , graphLines
        , undo
        , mouseX
        , mouseY
        } = app
    in
      { triangleStage = newTriangleStage
      , triangles = triangles
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      , undo = undo
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun undoTriangle
    (app: app_type, newTriangleStage: triangle_stage, trianglesTl) : app_type =
    let
      val
        { triangleStage = _
        , triangles = _
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , graphLines
        , undo
        , mouseX
        , mouseY
        } = app
    in
      { triangleStage = newTriangleStage
      , triangles = trianglesTl
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      , undo = undo
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun newTriangle (app: app_type, x1, y1, x2, y2, x3, y3, newUndoTuple) :
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
        , undo
        , mouseX
        , mouseY
        } = app

      val newTriangle = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
      val newTriangles = newTriangle :: triangles
      val newUndo = newUndoTuple :: undo
    in
      { triangleStage = NO_TRIANGLE
      , triangles = newTriangles
      , undo = newUndo
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun helpWindowResize
    (app: app_type, windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) :
    app_type =
    let
      val
        { xClickPoints = _
        , yClickPoints = _
        , windowWidth = _
        , windowHeight = _
        , graphLines = _
        , triangles
        , triangleStage
        , undo
        , mouseX
        , mouseY
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
      , undo = undo
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun windowResize (app: app_type, windowWidth, windowHeight) =
    if windowWidth = windowHeight then
      helpWindowResize
        (app, windowWidth, windowHeight, 0, windowWidth, 0, windowHeight)
    else if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val wStart = difference div 2
        val wFinish = wStart + windowHeight
      in
        helpWindowResize
          (app, windowWidth, windowHeight, wStart, wFinish, 0, windowHeight)
      end
    else
      let
        val difference = windowHeight - windowWidth
        val hStart = difference div 2
        val hFinish = hStart + windowWidth
      in
        helpWindowResize
          (app, windowWidth, windowHeight, 0, windowWidth, hStart, hFinish)
      end

  fun mousePosition (app: app_type, mouseX, mouseY) =
    let
      val
        { mouseX = _
        , mouseY = _
        , triangles
        , triangleStage
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , graphLines
        , undo
        } = app

    in
      { mouseX = mouseX
      , mouseY = mouseY
      , triangles = triangles
      , triangleStage = triangleStage
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , graphLines = graphLines
      , undo = undo
      }
    end
end
