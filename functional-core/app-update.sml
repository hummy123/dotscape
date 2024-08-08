signature APP_UPDATE =
sig
  val update: AppType.app_type *  InputMessage.t
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
                AppWith.newTriangleStage (model, newTriangleStage, newUndoTuple)
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
                AppWith.newTriangleStage (model, newTriangleStage, newUndoTuple)
            in
              (model, drawMsg)
            end
        | SECOND {x1, y1, x2, y2} =>
            let
              val model = AppWith.newTriangle
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
        let val model = AppWith.replaceTriangleStage (model, NO_TRIANGLE)
        in (model, CLEAR_BUTTONS)
        end
    | SECOND {x1, y1, x2, y2} =>
        (* Change FIRST to SECOND and redraw buttons. *)
        let
          val newTriangleStage = FIRST {x1 = x1, y1 = y1}
          val model = AppWith.replaceTriangleStage (model, newTriangleStage)

          val drawVec =
            TriangleStage.firstToVector (x1, y1, Vector.fromList [], model)
          val drawMsg = DRAW_BUTTON drawVec
        in
          (model, drawMsg)
        end
    | NO_TRIANGLE =>
        (case #triangles model of
           {x1, y1, x2, y2, ...} :: trianglesTl =>
             (* Have to slice off (x3, y3) from triangle head,
              * turn (x1, y1, x2, y2) into a triangleStage,
              * and redraw both triangle and triangleStage. *)
             let
               val triangleStage = SECOND {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
               val model =
                 AppWith.undoTriangle (model, triangleStage, trianglesTl)

               val newTriangleVec = Triangles.toVector model
               val drawVec = TriangleStage.secondToVector
                 (x1, y1, x2, y2, newTriangleVec, model)
               val drawMsg =
                 DRAW_TRIANGLES_AND_BUTTONS
                   {triangles = newTriangleVec, buttons = drawVec}
             in
               (model, drawMsg)
             end
         | [] =>
             (* Can't undo, because there are no actions to undo. *)
             (model, NO_DRAW))

  fun update (model: app_type, inputMsg) =
    case inputMsg of
      MOUSE_MOVE {x = mouseX, y = mouseY} =>
        let val model = AppWith.mousePosition (model, mouseX, mouseY)
        in mouseMoveOrRelease model
        end
    | MOUSE_LEFT_RELEASE => mouseMoveOrRelease model
    | MOUSE_LEFT_CLICK => mouseLeftClick model
    | RESIZE_WINDOW {width, height} =>
        resizeWindow (model, width, height)
    | UNDO_ACTION => undoAction model
end
