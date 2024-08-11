signature APP_UPDATE =
sig
  val update: AppType.app_type * InputMessage.t
              -> AppType.app_type * DrawMessage.t
end

structure AppUpdate :> APP_UPDATE =
struct
  open AppType
  open DrawMessage
  open InputMessage

  fun mouseMoveOrRelease (model: app_type) =
    let
      val
        { xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , mouseX
        , mouseY
        , ...
        } = model

      val (drawVec, _, _) = ClickPoints.getClickPosition
        ( mouseX
        , mouseY
        , 1.0
        , 0.0
        , 0.0
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        )
      val drawVec = TriangleStage.toVector (model, drawVec)
      val drawMsg = DRAW_BUTTON drawVec
    in
      (model, drawMsg)
    end

  fun mouseLeftClick (model: app_type) =
    let
      val
        { xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        , mouseX
        , mouseY
        , ...
        } = model

      val (buttonVec, hpos, vpos) = ClickPoints.getClickPosition
        ( mouseX
        , mouseY
        , 0.0
        , 0.0
        , 1.0
        , xClickPoints
        , yClickPoints
        , windowWidth
        , windowHeight
        )
      val newUndoTuple = (hpos, vpos)
    in
      if Vector.length buttonVec > 0 then
        case #triangleStage model of
          NO_TRIANGLE =>
            let
              val drawVec = TriangleStage.toVector (model, buttonVec)
              val drawMsg = DRAW_BUTTON drawVec

              val newTriangleStage = FIRST {x1 = hpos, y1 = vpos}
              val model =
                AppWith.addTriangleStage (model, newTriangleStage, newUndoTuple)
            in
              (model, drawMsg)
            end
        | FIRST {x1, y1} =>
            let
              val drawVec =
                TriangleStage.firstToVector (x1, y1, buttonVec, model)
              val drawMsg = DRAW_BUTTON drawVec

              val newTriangleStage = SECOND
                {x1 = x1, y1 = y1, x2 = hpos, y2 = vpos}
              val model =
                AppWith.addTriangleStage (model, newTriangleStage, newUndoTuple)
            in
              (model, drawMsg)
            end
        | SECOND {x1, y1, x2, y2} =>
            let
              val model = AppWith.addTriangle
                (model, x1, y1, x2, y2, hpos, vpos, newUndoTuple)

              val drawVec = Triangles.toVector model
              val drawMsg = DRAW_TRIANGLES_AND_RESET_BUTTONS drawVec
            in
              (model, drawMsg)
            end
      else
        (model, NO_DRAW)
    end

  fun resizeWindow (model, width, height) =
    let
      val model = AppWith.windowResize (model, width, height)
      val triangles = Triangles.toVector model
      val graphLines = #graphLines model
      val drawMsg =
        RESIZE_TRIANGLES_BUTTONS_AND_GRAPH
          {triangles = triangles, graphLines = graphLines}
    in
      (model, drawMsg)
    end

  fun undoAction model =
    case #triangleStage model of
      FIRST {x1, y1} =>
        (* Change FIRST to NO_TRIANGLE and clear buttons. *)
        let
          val model =
            AppWith.undo (model, NO_TRIANGLE, #triangles model, (x1, y1))
        in
          (model, CLEAR_BUTTONS)
        end
    | SECOND {x1, y1, x2, y2} =>
        (* Change FIRST to SECOND and redraw buttons. *)
        let
          val newTriangleStage = FIRST {x1 = x1, y1 = y1}
          val model =
            AppWith.undo (model, newTriangleStage, #triangles model, (x2, y2))

          val emptyVec: Real32.real vector = Vector.fromList []
          val drawVec = TriangleStage.firstToVector (x1, y1, emptyVec, model)
          val drawMsg = DRAW_BUTTON drawVec
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
               val emptyVec : Real32.real vector = Vector.fromList []
               val drawVec = TriangleStage.secondToVector
                 (x1, y1, x2, y2, emptyVec, model)
               val drawMsg =
                 DRAW_TRIANGLES_AND_BUTTONS
                   {triangles = newTriangleVec, buttons = drawVec}
             in
               (model, drawMsg)
             end
         | [] =>
             (* Can't undo, because there are no actions to undo. *)
             (model, NO_DRAW))

  fun redoAction model =
    case #redo model of
      (redoHd as (x, y)) :: tl =>
        (* There is a click point to redo. *)
        (case #triangleStage model of
           NO_TRIANGLE =>
             (* add to triangle stage, and redraw buttons *)
             let
               val newTriangleStage = FIRST {x1 = x, y1 = y}
               val model =
                 AppWith.redo
                   (model, newTriangleStage, #triangles model, redoHd)

               val emptyVec: Real32.real vector = Vector.fromList []
               val drawVec =
                 TriangleStage.firstToVector (x, y, emptyVec, model)
               val drawMsg = DRAW_BUTTON drawVec
             in
               (model, drawMsg)
             end
         | FIRST {x1, y1} =>
             (* add to triangle stage, redraw buttons *)
             let
               val newTriangleStage = SECOND {x1 = x1, y1 = y1, x2 = x, y2 = y}
               val model =
                 AppWith.redo
                   (model, newTriangleStage, #triangles model, redoHd)

               val emptyVec: Real32.real vector = Vector.fromList []
               val drawVec = TriangleStage.secondToVector
                 (x1, y1, x, y, emptyVec, model)
               val drawMsg = DRAW_BUTTON drawVec
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
               val drawMsg = DRAW_TRIANGLES_AND_RESET_BUTTONS drawVec
             in
               (model, drawMsg)
             end)
    | [] => 
        (* Nothing to redo. *) 
        (model, NO_DRAW)

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
end
