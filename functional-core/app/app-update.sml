signature APP_UPDATE =
sig
  val update: AppType.app_type * InputMessage.t
              -> AppType.app_type * UpdateMessage.t list
end

structure AppUpdate :> APP_UPDATE =
struct
  open AppType

  open DrawMessage
  open FileMessage
  open InputMessage
  open UpdateMessage

  fun getDotVecFromIndices (model, hIdx, vIdx) =
    let
      val {windowWidth, windowHeight, ...} = model
      val xpos = Vector.sub (#xClickPoints model, hIdx)
      val ypos = Vector.sub (#yClickPoints model, vIdx)
    in
      ClickPoints.getDrawDotRgb
        (xpos, ypos, 1.0, 0.0, 0.0, windowWidth, windowHeight)
    end

  fun mouseMoveOrRelease (model: app_type) =
    let
      val drawVec =
        case ClickPoints.getClickPositionFromMouse model of
          SOME (hIdx, vIdx) => getDotVecFromIndices (model, hIdx, vIdx)
        | NONE => Vector.fromList []
      val drawVec = TriangleStage.toVector (model, drawVec)

      val drawMsg = DRAW_DOT drawVec
      val drawMsg = [DRAW drawMsg]
    in
      (model, drawMsg)
    end

  fun getDrawDotMsgWhenArrowIsAtBoundary model =
    let
      val {arrowX, arrowY, ...} = model
      val dotVec = getDotVecFromIndices (model, arrowX, arrowY)
      val dotVec = TriangleStage.toVector (model, dotVec)
      val drawMsg = DRAW_DOT dotVec
      val drawMsg = [DRAW drawMsg]
    in
      (model, drawMsg)
    end

  fun moveArrowUp (model: app_type) =
    let
      val {arrowX, arrowY, ...} = model
    in
      if arrowY > 0 then
        let
          val newArrowY = arrowY - 1
          val model = AppWith.arrowY (model, newArrowY)

          val dotVec = getDotVecFromIndices (model, arrowX, newArrowY)
          val dotVec = TriangleStage.toVector (model, dotVec)
          val drawMsg = DRAW_DOT dotVec
          val drawMsg = [DRAW drawMsg]
        in
          (model, drawMsg)
        end
      else
        getDrawDotMsgWhenArrowIsAtBoundary model
    end

  fun moveArrowLeft (model: app_type) =
    let
      val {arrowX, arrowY, ...} = model
    in
      if arrowX > 0 then
        let
          val newArrowX = arrowX - 1
          val model = AppWith.arrowX (model, newArrowX)

          val dotVec = getDotVecFromIndices (model, newArrowX, arrowY)
          val dotVec = TriangleStage.toVector (model, dotVec)
          val drawMsg = DRAW_DOT dotVec
          val drawMsg = [DRAW drawMsg]
        in
          (model, drawMsg)
        end
      else
        getDrawDotMsgWhenArrowIsAtBoundary model
    end

  fun moveArrowRight (model: app_type) =
    let
      val {arrowX, arrowY, xClickPoints, ...} = model
    in
      if arrowX < Vector.length xClickPoints - 1 then
        let
          val newArrowX = arrowX + 1
          val model = AppWith.arrowX (model, newArrowX)

          val dotVec = getDotVecFromIndices (model, newArrowX, arrowY)
          val dotVec = TriangleStage.toVector (model, dotVec)
          val drawMsg = DRAW_DOT dotVec
          val drawMsg = [DRAW drawMsg]
        in
          (model, drawMsg)
        end
      else
        getDrawDotMsgWhenArrowIsAtBoundary model
    end

  fun moveArrowDown (model: app_type) =
    let
      val {arrowX, arrowY, yClickPoints, ...} = model
    in
      if arrowY < Vector.length yClickPoints - 1 then
        let
          val newArrowY = arrowY + 1
          val model = AppWith.arrowY (model, newArrowY)

          val dotVec = getDotVecFromIndices (model, arrowX, newArrowY)
          val dotVec = TriangleStage.toVector (model, dotVec)
          val drawMsg = DRAW_DOT dotVec
          val drawMsg = [DRAW drawMsg]
        in
          (model, drawMsg)
        end
      else
        getDrawDotMsgWhenArrowIsAtBoundary model
    end

  fun addCoordinates (model: app_type, hIdx, vIdx) =
    let
      val
        { windowWidth
        , windowHeight
        , xClickPoints
        , yClickPoints
        , triangleStage
        , ...
        } = model

      val xpos = Vector.sub (xClickPoints, hIdx)
      val ypos = Vector.sub (yClickPoints, vIdx)
      val dotVec = ClickPoints.getDrawDotRgb
        (xpos, ypos, 0.0, 0.0, 1.0, windowWidth, windowHeight)

      val halfWidth = Real32.fromInt (windowWidth div 2)
      val halfHeight = Real32.fromInt (windowHeight div 2)
      val hpos =
        ClickPoints.xposToNdc (xpos, windowWidth, windowHeight, halfWidth)
      val vpos =
        ClickPoints.yposToNdc (ypos, windowWidth, windowHeight, halfHeight)

      val newUndoTuple = (hpos, vpos)
    in
      case triangleStage of
        NO_TRIANGLE =>
          let
            val drawVec = TriangleStage.toVector (model, dotVec)
            val drawMsg = DRAW_DOT drawVec
            val drawMsg = [DRAW drawMsg]

            val newTriangleStage = FIRST {x1 = hpos, y1 = vpos}
            val model = AppWith.addTriangleStage
              (model, newTriangleStage, newUndoTuple, hIdx, vIdx)
          in
            (model, drawMsg)
          end
      | FIRST {x1, y1} =>
          let
            val drawVec = TriangleStage.firstToVector (x1, y1, dotVec, model)
            val drawMsg = DRAW_DOT drawVec
            val drawMsg = [DRAW drawMsg]

            val newTriangleStage = SECOND
              {x1 = x1, y1 = y1, x2 = hpos, y2 = vpos}
            val model = AppWith.addTriangleStage
              (model, newTriangleStage, newUndoTuple, hIdx, vIdx)
          in
            (model, drawMsg)
          end
      | SECOND {x1, y1, x2, y2} =>
          let
            val model = AppWith.addTriangle
              (model, x1, y1, x2, y2, hpos, vpos, newUndoTuple, hIdx, vIdx)
            val drawVec = Triangles.toVector model
            val drawMsg = DRAW_TRIANGLES_AND_RESET_DOTS drawVec
            val drawMsg = [DRAW drawMsg]
          in
            (model, drawMsg)
          end
    end

  fun mouseLeftClick model =
    case ClickPoints.getClickPositionFromMouse model of
      SOME (hIdx, vIdx) => addCoordinates (model, hIdx, vIdx)
    | NONE => (model, [])

  fun enterOrSpaceCoordinates model =
    let val {arrowX, arrowY, ...} = model
    in addCoordinates (model, arrowX, arrowY)
    end

  fun resizeWindow (model, width, height) =
    let
      val model = AppWith.windowResize (model, width, height)
      val triangles = Triangles.toVector model

      val graphLines =
        if #showGraph model then GraphLines.generate model
        else Vector.fromList []

      val dots = TriangleStage.toVector (model, Vector.fromList [])

      val drawMsg =
        RESIZE_TRIANGLES_DOTS_AND_GRAPH
          {triangles = triangles, graphLines = graphLines, dots = dots}
      val drawMsg = [DRAW drawMsg]
    in
      (model, drawMsg)
    end

  fun undoAction model =
    case #triangleStage model of
      FIRST {x1, y1} =>
        (* Change FIRST to NO_TRIANGLE and clear dots. *)
        let
          val model =
            AppWith.undo (model, NO_TRIANGLE, #triangles model, (x1, y1))
        in
          (model, [DRAW CLEAR_DOTS])
        end
    | SECOND {x1, y1, x2, y2} =>
        (* Change FIRST to SECOND and redraw dots. *)
        let
          val newTriangleStage = FIRST {x1 = x1, y1 = y1}
          val model =
            AppWith.undo (model, newTriangleStage, #triangles model, (x2, y2))

          val emptyVec: Real32.real vector = Vector.fromList []
          val drawVec = TriangleStage.firstToVector (x1, y1, emptyVec, model)
          val drawMsg = DRAW_DOT drawVec
          val drawMsg = [DRAW drawMsg]
        in
          (model, drawMsg)
        end
    | NO_TRIANGLE =>
        (case #triangles model of
           {x1, y1, x2, y2, x3, y3} :: trianglesTl =>
             (* Have to slice off (x3, y3) from triangle head,
              * turn (x1, y1, x2, y2) into a triangleStage,
              * and redraw both triangle and triangleStage. *)
             let
               val triangleStage = SECOND {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
               val model =
                 AppWith.undo (model, triangleStage, trianglesTl, (x3, y3))

               val newTriangleVec = Triangles.toVector model
               val emptyVec: Real32.real vector = Vector.fromList []
               val drawVec = TriangleStage.secondToVector
                 (x1, y1, x2, y2, emptyVec, model)
               val drawMsg =
                 DRAW_TRIANGLES_AND_DOTS
                   {triangles = newTriangleVec, dots = drawVec}
               val drawMsg = [DRAW drawMsg]
             in
               (model, drawMsg)
             end
         | [] =>
             (* Can't undo, because there are no actions to undo. *)
             (model, []))

  fun redoAction model =
    case #redo model of
      (redoHd as (x, y)) :: tl =>
        (* There is a click point to redo. *)
        (case #triangleStage model of
           NO_TRIANGLE =>
             (* add to triangle stage, and redraw dots *)
             let
               val newTriangleStage = FIRST {x1 = x, y1 = y}
               val model =
                 AppWith.redo
                   (model, newTriangleStage, #triangles model, redoHd)

               val emptyVec: Real32.real vector = Vector.fromList []
               val drawVec = TriangleStage.firstToVector (x, y, emptyVec, model)
               val drawMsg = DRAW_DOT drawVec
               val drawMsg = [DRAW drawMsg]
             in
               (model, drawMsg)
             end
         | FIRST {x1, y1} =>
             (* add to triangle stage, redraw dots *)
             let
               val newTriangleStage = SECOND {x1 = x1, y1 = y1, x2 = x, y2 = y}
               val model =
                 AppWith.redo
                   (model, newTriangleStage, #triangles model, redoHd)

               val emptyVec: Real32.real vector = Vector.fromList []
               val drawVec = TriangleStage.secondToVector
                 (x1, y1, x, y, emptyVec, model)
               val drawMsg = DRAW_DOT drawVec
               val drawMsg = [DRAW drawMsg]
             in
               (model, drawMsg)
             end
         | SECOND {x1, y1, x2, y2} =>
             (* clear triangle stage, add to trinagle list and redraw triangles *)
             let
               val newTriangleStage = NO_TRIANGLE
               val newTriangle =
                 {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x, y3 = y}
               val newTriangles = newTriangle :: (#triangles model)
               val model =
                 AppWith.redo (model, newTriangleStage, newTriangles, redoHd)

               val drawVec = Triangles.toVector model
               val drawMsg = DRAW_TRIANGLES_AND_RESET_DOTS drawVec
               val drawMsg = [DRAW drawMsg]
             in
               (model, drawMsg)
             end)
    | [] => (* Nothing to redo. *) (model, [])

  fun toggleGraph (model: app_type) =
    if #showGraph model then
      let
        val model = AppWith.graphVisibility (model, false)
        val drawMsg = DRAW_GRAPH (Vector.fromList [])
        val drawMsg = [DRAW drawMsg]
      in
        (model, drawMsg)
      end
    else
      let
        val model = AppWith.graphVisibility (model, true)
        val graphLines = GraphLines.generate model
        val drawMsg = DRAW_GRAPH graphLines
        val drawMsg = [DRAW drawMsg]
      in
        (model, drawMsg)
      end

  fun getSaveTrianglesMsg model =
    let
      val {triangles, ...} = model
      val fileMsg = SAVE_TRIANGLES triangles
      val fileMsg = [FILE fileMsg]
    in
      (model, fileMsg)
    end

  fun getLoadTrianglesMsg model =
    (model, [FILE LOAD_TRIANGLES])

  fun getExportTrianglesMsg model =
    let
      val {triangles, ...} = model
      val fileMsg = EXPORT_TRIANGLES (#triangles model)
      val fileMsg = [FILE fileMsg]
    in
      (model, fileMsg)
    end

  fun useTrianglesInNormalMode (model, triangles) =
    let
      val model = AppWith.useTrianglesAndSetNormalMode (model, triangles)
      val drawVec = Triangles.toVector model
      val drawMsg = DRAW_TRIANGLES_AND_RESET_DOTS drawVec
      val drawMsg = [DRAW drawMsg]
    in
      (model, drawMsg)
    end

  fun trianglesLoadError model = (model, [])

  fun enterBrowseMode model =
    let
      val model = AppWith.mode (model, AppType.BROWSE_MODE)
      (* todo: should draw modal window as well *)
      val fileMsg = LOAD_FILES (#openFilePath model)
      val fileMsg = [FILE fileMsg]
    in
      (model, fileMsg)
    end

  fun handleFileBrowserAndPathInNormalMode (model, fileBrowser, path) =
    let val model = AppWith.fileBrowserAndPath (model, fileBrowser, path)
    in (model, [])
    end

  fun updateNormalMode (model: app_type, inputMsg) =
    case inputMsg of
      MOUSE_MOVE {x = mouseX, y = mouseY} =>
        let val model = AppWith.mousePosition (model, mouseX, mouseY)
        in mouseMoveOrRelease model
        end
    | MOUSE_LEFT_RELEASE => mouseMoveOrRelease model
    | MOUSE_LEFT_CLICK => mouseLeftClick model
    | RESIZE_WINDOW {width, height} => resizeWindow (model, width, height)
    | UNDO_ACTION => undoAction model
    | REDO_ACTION => redoAction model
    | KEY_G => toggleGraph model
    | KEY_CTRL_S => getSaveTrianglesMsg model
    | KEY_CTRL_L => getLoadTrianglesMsg model
    | KEY_CTRL_E => getExportTrianglesMsg model
    | KEY_CTRL_O => enterBrowseMode model
    | ARROW_UP => moveArrowUp model
    | ARROW_LEFT => moveArrowLeft model
    | ARROW_RIGHT => moveArrowRight model
    | ARROW_DOWN => moveArrowDown model
    | KEY_ENTER => enterOrSpaceCoordinates model
    | KEY_SPACE => enterOrSpaceCoordinates model
    | USE_TRIANGLES triangles => useTrianglesInNormalMode (model, triangles)
    | TRIANGLES_LOAD_ERROR => trianglesLoadError model
    | FILE_BROWSER_AND_PATH {fileBrowser, path} =>
        handleFileBrowserAndPathInNormalMode (model, fileBrowser, path)

  fun stringToVec
    (pos, str, acc, startX, startY, windowWidth, windowHeight, r, g, b) =
    if pos = String.size str then
      acc
    else
      let
        val chr = String.sub (str, pos)
        val chrFun = Vector.sub (CozetteAscii.asciiTable, Char.ord chr)
        val chrVec = chrFun
          (startX, startY, 25.0, 25.0, windowWidth, windowHeight, r, g, b)
        val acc = chrVec :: acc
      in
        stringToVec
          ( pos + 1
          , str
          , acc
          , startX + 12
          , startY
          , windowWidth
          , windowHeight
          , r
          , g
          , b
          )
      end

  fun buildFileBrowserText
    (pos, fileBrowser, acc, startY, windowWidth, windowHeight, selectedIdx) =
    if pos = Vector.length fileBrowser then
      Vector.concat acc
    else
      let
        val item = Vector.sub (fileBrowser, pos)
        val itemText =
          case item of
            IS_FILE str => str
          | IS_FOLDER str => str
        val acc =
          if pos <> selectedIdx then
            stringToVec
              ( 0
              , itemText
              , acc
              , 10
              , startY
              , windowWidth
              , windowHeight
              , 0.0
              , 0.0
              , 0.0
              )
          else
            stringToVec
              ( 0
              , itemText
              , acc
              , 10
              , startY
              , windowWidth
              , windowHeight
              , 0.35
              , 0.35
              , 0.75
              )
      in
        buildFileBrowserText
          ( pos + 1
          , fileBrowser
          , acc
          , startY + 23
          , windowWidth
          , windowHeight
          , selectedIdx
          )
      end

  fun redrawFileBrowser (model: app_type) =
    let
      val {windowWidth, windowHeight, fileBrowser, fileBrowserIdx, ...} = model
      val ww = Real32.fromInt windowWidth
      val wh = Real32.fromInt windowHeight
      val textVec = buildFileBrowserText
        (0, fileBrowser, [], 10, ww, wh, fileBrowserIdx)

      val drawMsg = DRAW_MODAL_TEXT textVec
    in
      (model, [DRAW drawMsg])
    end

  fun handleFileBrowserAndPathInBrowseMode (model, fileBrowser, path) =
    let val model = AppWith.fileBrowserAndPath (model, fileBrowser, path)
    in redrawFileBrowser model
    end

  fun browseModeArrowUp (model: app_type) =
    let
      val {fileBrowser, fileBrowserIdx, ...} = model

      val fileBrowserIdx =
        if fileBrowserIdx > 0 then fileBrowserIdx - 1
        else Int.max (0, Vector.length fileBrowser - 1)

      val model = AppWith.fileBrowserIdx (model, fileBrowserIdx)
    in
      redrawFileBrowser model
    end

  fun browseModeArrowDown (model: app_type) =
    let
      val {fileBrowser, fileBrowserIdx, ...} = model

      val fileBrowserIdx =
        if fileBrowserIdx = Vector.length fileBrowser - 1 then 0
        else fileBrowserIdx + 1

      val model = AppWith.fileBrowserIdx (model, fileBrowserIdx)
    in
      redrawFileBrowser model
    end

  fun selectCurrentFileItem model =
    let
      val {fileBrowser, fileBrowserIdx, openFilePath, ...} = model
    in
      if Vector.length fileBrowser > 0 then
        let
          val path =
            case Vector.sub (fileBrowser, fileBrowserIdx) of
              IS_FILE str => str
            | IS_FOLDER str => str
          val path = String.concat [openFilePath, "/", path]
          val fileMsg = SELECT_PATH path
        in
          (model, [FILE fileMsg])
        end
      else
        (model, [])
    end

  fun updateBrowseMode (model: app_type, inputMsg) =
    case inputMsg of
      ARROW_UP => browseModeArrowUp model
    | ARROW_DOWN => browseModeArrowDown model
    | TRIANGLES_LOAD_ERROR => trianglesLoadError model
    (* todo: 
    | ARROW_LEFT =>
    *)
    | ARROW_RIGHT => selectCurrentFileItem model
    | KEY_ENTER => selectCurrentFileItem model
    | KEY_SPACE => selectCurrentFileItem model
    | FILE_BROWSER_AND_PATH {fileBrowser, path} =>
        handleFileBrowserAndPathInBrowseMode (model, fileBrowser, path)
    | USE_TRIANGLES triangles => useTrianglesInNormalMode (model, triangles)
    | _ => (model, [])

  fun update (model: app_type, inputMsg) =
    case #mode model of
      NORMAL_MODE => updateNormalMode (model, inputMsg)
    | BROWSE_MODE => updateBrowseMode (model, inputMsg)
end
