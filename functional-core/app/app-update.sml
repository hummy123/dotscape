signature APP_UPDATE =
sig
  val update: AppType.app_type * InputMessage.t
              -> AppType.app_type * UpdateMessage.t
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
      val xpos = Vector.sub (#xClickPoints model, hIdx)
      val ypos = Vector.sub (#yClickPoints model, vIdx)
    in
      ClickPoints.getDrawDot (xpos, ypos, 1.0, 0.0, 0.0, model)
    end

  fun mouseMoveOrRelease (model: app_type) =
    let
      val drawVec =
        case ClickPoints.getClickPositionFromMouse model of
          SOME (hIdx, vIdx) => getDotVecFromIndices (model, hIdx, vIdx)
        | NONE => Vector.fromList []
      val drawVec = TriangleStage.toVector (model, drawVec)

      val drawMsg = DRAW_DOT drawVec
    in
      (model, DRAW drawMsg)
    end

  fun getDrawDotMsgWhenArrowIsAtBoundary model =
    let
      val {arrowX, arrowY, ...} = model
      val dotVec = getDotVecFromIndices (model, arrowX, arrowY)
      val dotVec = TriangleStage.toVector (model, dotVec)
      val drawMsg = DRAW_DOT dotVec
    in
      (model, DRAW drawMsg)
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
        in
          (model, DRAW drawMsg)
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
        in
          (model, DRAW drawMsg)
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
        in
          (model, DRAW drawMsg)
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
        in
          (model, DRAW drawMsg)
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
      val dotVec = ClickPoints.getDrawDot (xpos, ypos, 0.0, 0.0, 1.0, model)

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

            val newTriangleStage = FIRST {x1 = hpos, y1 = vpos}
            val model = AppWith.addTriangleStage
              (model, newTriangleStage, newUndoTuple, hIdx, vIdx)
          in
            (model, DRAW drawMsg)
          end
      | FIRST {x1, y1} =>
          let
            val drawVec = TriangleStage.firstToVector (x1, y1, dotVec, model)
            val drawMsg = DRAW_DOT drawVec

            val newTriangleStage = SECOND
              {x1 = x1, y1 = y1, x2 = hpos, y2 = vpos}
            val model = AppWith.addTriangleStage
              (model, newTriangleStage, newUndoTuple, hIdx, vIdx)
          in
            (model, DRAW drawMsg)
          end
      | SECOND {x1, y1, x2, y2} =>
          let
            val model = AppWith.addTriangle
              (model, x1, y1, x2, y2, hpos, vpos, newUndoTuple, hIdx, vIdx)
            val drawVec = Triangles.toVector model
            val drawMsg = DRAW_TRIANGLES_AND_RESET_DOTS drawVec
          in
            (model, DRAW drawMsg)
          end
    end

  fun mouseLeftClick model =
    case ClickPoints.getClickPositionFromMouse model of
      SOME (hIdx, vIdx) => addCoordinates (model, hIdx, vIdx)
    | NONE => (model, NO_MAILBOX)

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
    in
      (model, DRAW drawMsg)
    end

  fun undoAction model =
    case #triangleStage model of
      FIRST {x1, y1} =>
        (* Change FIRST to NO_TRIANGLE and clear dots. *)
        let
          val model =
            AppWith.undo (model, NO_TRIANGLE, #triangles model, (x1, y1))
        in
          (model, DRAW CLEAR_DOTS)
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
        in
          (model, DRAW drawMsg)
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
             in
               (model, DRAW drawMsg)
             end
         | [] =>
             (* Can't undo, because there are no actions to undo. *)
             (model, NO_MAILBOX))

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
             in
               (model, DRAW drawMsg)
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
             in
               (model, DRAW drawMsg)
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
             in
               (model, DRAW drawMsg)
             end)
    | [] => (* Nothing to redo. *) (model, NO_MAILBOX)

  fun toggleGraph (model: app_type) =
    if #showGraph model then
      let
        val model = AppWith.graphVisibility (model, false)
        val drawMsg = DRAW_GRAPH (Vector.fromList [])
      in
        (model, DRAW drawMsg)
      end
    else
      let
        val model = AppWith.graphVisibility (model, true)
        val graphLines = GraphLines.generate model
        val drawMsg = DRAW_GRAPH graphLines
      in
        (model, DRAW drawMsg)
      end

  fun getSaveTrianglesMsg model =
    let
      val {triangles, ...} = model
      val fileMsg = SAVE_TRIANGLES triangles
    in
      (model, FILE fileMsg)
    end

  fun getLoadTrianglesMsg model = (model, FILE LOAD_TRIANGLES)

  fun getExportTrianglesMsg model =
    let
      val {triangles, ...} = model
      val fileMsg = EXPORT_TRIANGLES (#triangles model)
    in
      (model, FILE fileMsg)
    end

  fun useTriangles (model, triangles) =
    let
      val model = AppWith.useTriangles (model, triangles)
      val drawVec = Triangles.toVector model
      val drawMsg = DRAW_TRIANGLES_AND_RESET_DOTS drawVec
    in
      (model, DRAW drawMsg)
    end

  fun trianglesLoadError model = (model, NO_MAILBOX)

  fun update (model: app_type, inputMsg) =
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
    | ARROW_UP => moveArrowUp model
    | ARROW_LEFT => moveArrowLeft model
    | ARROW_RIGHT => moveArrowRight model
    | ARROW_DOWN => moveArrowDown model
    | KEY_ENTER => enterOrSpaceCoordinates model
    | KEY_SPACE => enterOrSpaceCoordinates model
    | USE_TRIANGLES triangles => useTriangles (model, triangles)
    | TRIANGLES_LOAD_ERROR => trianglesLoadError model
end
