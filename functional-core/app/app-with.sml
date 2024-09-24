signature APP_WITH =
sig
  val graphVisibility: AppType.app_type * bool -> AppType.app_type

  val windowResize: AppType.app_type * int * int -> AppType.app_type

  val mousePosition: AppType.app_type * Real32.real * Real32.real
                     -> AppType.app_type

  val arrowX: AppType.app_type * int -> AppType.app_type
  val arrowY: AppType.app_type * int -> AppType.app_type

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
    AppType.app_type
    * AppType.triangle_stage
    * (Real32.real * Real32.real)
    * int
    * int
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
    * int
    * int
    -> AppType.app_type

  val useTriangles: AppType.app_type * AppType.triangle list -> AppType.app_type
end

structure AppWith :> APP_WITH =
struct
  open AppType

  (* add to undo, clear redo *)
  fun addTriangleStage
    (app: app_type, newTriangleStage: triangle_stage, newUndoHd, arrowX, arrowY) :
    app_type =
    let
      val
        { triangleStage = _
        , mode
        , triangles
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo = _
        , showGraph
        , mouseX
        , mouseY
        , arrowX = _
        , arrowY = _
        } = app

      val newUndo = newUndoHd :: undo
    in
      { triangleStage = newTriangleStage
      , undo = newUndo
      , redo = []
      , mode = mode
      , triangles = triangles
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun addTriangle
    (app: app_type, x1, y1, x2, y2, x3, y3, newUndoHd, arrowX, arrowY) :
    app_type =
    let
      val
        { mode
        , triangles
        , triangleStage = _
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo = _
        , showGraph
        , mouseX
        , mouseY
        , arrowX = _
        , arrowY = _
        } = app

      val newTriangle = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
      val newTriangles = newTriangle :: triangles
      val newUndo = newUndoHd :: undo
    in
      { mode = mode
      , triangleStage = NO_TRIANGLE
      , triangles = newTriangles
      , undo = newUndo
      , redo = []
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun arrowX (app: app_type, arrowX) =
    let
      val
        { mode
        , xClickPoints
        , yClickPoints
        , numClickPoints
        , windowWidth
        , windowHeight
        , triangles
        , triangleStage
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX = _
        , arrowY
        } = app
    in
      { mode = mode
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , numClickPoints = numClickPoints
      , triangles = triangles
      , triangleStage = triangleStage
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , undo = undo
      , redo = redo
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun arrowY (app: app_type, arrowY) =
    let
      val
        { mode
        , xClickPoints
        , yClickPoints
        , numClickPoints
        , windowWidth
        , windowHeight
        , triangles
        , triangleStage
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX
        , arrowY = _
        } = app
    in
      { mode = mode
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , numClickPoints = numClickPoints
      , triangles = triangles
      , triangleStage = triangleStage
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , undo = undo
      , redo = redo
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun helpWindowResize
    (app: app_type, windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) :
    app_type =
    let
      val
        { mode
        , xClickPoints = _
        , yClickPoints = _
        , numClickPoints
        , windowWidth = _
        , windowHeight = _
        , triangles
        , triangleStage
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX
        , arrowY
        } = app

      val xClickPoints = ClickPoints.generate (wStart, wFinish, numClickPoints)
      val yClickPoints = ClickPoints.generate (hStart, hFinish, numClickPoints)
    in
      { mode = mode
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , numClickPoints = numClickPoints
      , triangles = triangles
      , triangleStage = triangleStage
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , undo = undo
      , redo = redo
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
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
        { mode
        , mouseX = _
        , mouseY = _
        , triangles
        , triangleStage
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , showGraph
        , arrowX
        , arrowY
        } = app
    in
      { mode = mode
      , mouseX = mouseX
      , mouseY = mouseY
      , triangles = triangles
      , triangleStage = triangleStage
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , undo = undo
      , redo = redo
      , showGraph = showGraph
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  (* add to redo, pop one from undo *)
  fun undo (app: app_type, newTriangleStage, newTriangles, newRedoHd) =
    let
      val
        { mode
        , triangleStage = _
        , triangles = _
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX
        , arrowY
        } = app

      val newUndo =
        case undo of
          hd :: tl => tl
        | empty => empty

      val newRedo = newRedoHd :: redo
    in
      { mode = mode
      , triangleStage = newTriangleStage
      , triangles = newTriangles
      , undo = newUndo
      , redo = newRedo
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  (* add to undo, pop one from redo *)
  fun redo (app: app_type, newTriangleStage, newTriangles, newUndoHd) =
    let
      val
        { mode
        , triangleStage = _
        , triangles = _
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX
        , arrowY
        } = app

      val newUndo = newUndoHd :: undo
      val newRedo =
        case redo of
          hd :: tl => tl
        | empty => empty
    in
      { mode = mode
      , triangleStage = newTriangleStage
      , triangles = newTriangles
      , undo = newUndo
      , redo = newRedo
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , showGraph = showGraph
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun graphVisibility (app: app_type, shouldShowGraph) =
    let
      val
        { mode
        , triangleStage
        , triangles
        , numClickPoints
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , mouseX
        , mouseY
        , arrowX
        , arrowY
        , showGraph = _
        } = app
    in
      { mode = mode
      , showGraph = shouldShowGraph
      , triangleStage = triangleStage
      , triangles = triangles
      , undo = undo
      , redo = redo
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end

  fun useTriangles (app: app_type, triangles) =
    let
      val
        { mode
        , xClickPoints
        , yClickPoints
        , numClickPoints
        , windowWidth
        , windowHeight
        , undo
        , redo
        , showGraph
        , mouseX
        , mouseY
        , arrowX
        , arrowY
        , triangles = _
        , triangleStage = _
        } = app

      val triangleStage = NO_TRIANGLE
    in
      { mode = mode
      , triangleStage = triangleStage
      , triangles = triangles
      , undo = []
      , redo = []
      , showGraph = showGraph
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , mouseX = mouseX
      , mouseY = mouseY
      , arrowX = arrowX
      , arrowY = arrowY
      }
    end
end
