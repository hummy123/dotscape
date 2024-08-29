signature APP_WITH =
sig
  val graphVisibility: AppType.app_type * bool -> AppType.app_type

  val windowResize: AppType.app_type * int * int -> AppType.app_type

  val mousePosition: AppType.app_type * Real32.real * Real32.real
                     -> AppType.app_type

  val undo:
    AppType.app_type
    * AppType.triangle_stage
    * AppType.triangle list
    * (Real32.real * Real32.real)
    -> AppType.app_type

  val redo:
    AppType.app_type
    * AppType.triangle_stage
    * AppType.triangle list
    * (Real32.real * Real32.real)
    -> AppType.app_type

  (* 
   * add functions clear the redo stack, 
   * as they are meant to be called after a click action,
   * and also add new click position to undo stack.
   *)
  val addTriangleStage:
    AppType.app_type * AppType.triangle_stage * (Real32.real * Real32.real)
    -> AppType.app_type

  val addTriangle:
    AppType.app_type
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * Real32.real
    * (Real32.real * Real32.real)
    -> AppType.app_type

  val useTriangles: AppType.app_type * AppType.triangle list -> AppType.app_type
end

structure AppWith :> APP_WITH =
struct
  open AppType

  (* add to undo, clear redo *)
  fun addTriangleStage
    (app: app_type, newTriangleStage: triangle_stage, newUndoHd) : app_type =
    let
      val
        { triangleStage = _
        , triangles
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo = _
        , mouseX
        , mouseY
        , showGraph
        } = app

      val newUndo = newUndoHd :: undo
    in
      { triangleStage = newTriangleStage
      , undo = newUndo
      , redo = []
      , triangles = triangles
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , showGraph = showGraph
      }
    end

  fun addTriangle (app: app_type, x1, y1, x2, y2, x3, y3, newUndoHd) : app_type =
    let
      val
        { triangles
        , triangleStage = _
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo = _
        , mouseX
        , mouseY
        , showGraph
        } = app

      val newTriangle = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
      val newTriangles = newTriangle :: triangles
      val newUndo = newUndoHd :: undo
    in
      { triangleStage = NO_TRIANGLE
      , triangles = newTriangles
      , undo = newUndo
      , redo = []
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , showGraph = showGraph
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
        , triangles
        , triangleStage
        , undo
        , redo
        , mouseX
        , mouseY
        , showGraph
        } = app

      val xClickPoints = ClickPoints.generate (wStart, wFinish)
      val yClickPoints = ClickPoints.generate (hStart, hFinish)
    in
      { xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , triangles = triangles
      , triangleStage = triangleStage
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , undo = undo
      , redo = redo
      , mouseX = mouseX
      , mouseY = mouseY
      , showGraph = showGraph
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
        , undo
        , redo
        , showGraph
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
      , undo = undo
      , redo = redo
      , showGraph = showGraph
      }
    end

  (* add to redo, pop one from undo *)
  fun undo (app: app_type, newTriangleStage, newTriangles, newRedoHd) =
    let
      val
        { triangleStage = _
        , triangles = _
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , mouseX
        , mouseY
        , showGraph
        } = app

      val newUndo =
        case undo of
          hd :: tl => tl
        | empty => empty

      val newRedo = newRedoHd :: redo
    in
      { triangleStage = newTriangleStage
      , triangles = newTriangles
      , undo = newUndo
      , redo = newRedo
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , showGraph = showGraph
      }
    end

  (* add to undo, pop one from redo *)
  fun redo (app: app_type, newTriangleStage, newTriangles, newUndoHd) =
    let
      val
        { triangleStage = _
        , triangles = _
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , mouseX
        , mouseY
        , showGraph
        } = app

      val newUndo = newUndoHd :: undo
      val newRedo =
        case redo of
          hd :: tl => tl
        | empty => empty
    in
      { triangleStage = newTriangleStage
      , triangles = newTriangles
      , undo = newUndo
      , redo = newRedo
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , showGraph = showGraph
      }
    end

  fun graphVisibility (app: app_type, shouldShowGraph) =
    let
      val
        { triangleStage
        , triangles
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , mouseX
        , mouseY
        , showGraph = _
        } = app
    in
      { showGraph = shouldShowGraph
      , triangleStage = triangleStage
      , triangles = triangles
      , undo = undo
      , redo = redo
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end

  fun useTriangles (app: app_type, triangles) =
    let
      val
        { xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , mouseX
        , mouseY
        , showGraph
        , triangles = _
        , triangleStage = _
        } = app

      val triangleStage = NO_TRIANGLE
    in
      { triangleStage = triangleStage
      , triangles = triangles
      , undo = []
      , redo = []
      , showGraph = showGraph
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      }
    end
end
