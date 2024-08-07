signature APP_UPDATE =
sig
  val update: AppType.app_type * int * int * InputMessage.t
              -> AppType.app_type * int * int * DrawMessage.t
end

structure AppUpdate :> APP_UPDATE =
struct
  open AppType
  open DrawMessage
  open InputMessage

  fun mouseMoveOrRelease (model: app_type, mouseX, mouseY) =
    let
      val {xClickPoints, yClickPoints, ...} = model
      val (drawVec, _, _) = ClickPoints.getClickPosition
        (mouseX, mouseY, 1.0, 0.0, 0.0, model)
      val drawVec = TriangleStage.toVector (model, drawVec)
      val drawMsg = DRAW_BUTTON drawVec
    in
      (model, drawMsg, mouseX, mouseY)
    end

  fun mouseLeftClick (model: app_type, mouseX, mouseY) =
    let
      val {xClickPoints, yClickPoints, ...} = model
      val (buttonVec, hpos, vpos) = ClickPoints.getClickPosition
        (mouseX, mouseY, 0.0, 0.0, 1.0, model)
    in
      if Vector.length buttonVec > 0 then
        case #triangleStage model of
          NO_TRIANGLE =>
            let
              val drawVec = TriangleStage.toVector (model, buttonVec)
              val drawMsg = DRAW_BUTTON drawVec

              val newTriangleStage = FIRST {x1 = hpos, y1 = vpos}
              val model = AppType.withTriangleStage (model, newTriangleStage)
            in
              (model, drawMsg, mouseX, mouseY)
            end
        | FIRST {x1, y1} =>
            let
              val drawVec =
                TriangleStage.firstToVector (x1, y1, buttonVec, model)
              val drawMsg = DRAW_BUTTON drawVec

              val newTriangleStage = SECOND
                {x1 = x1, y1 = y1, x2 = hpos, y2 = vpos}
              val model = AppType.withTriangleStage (model, newTriangleStage)
            in
              (model, drawMsg, mouseX, mouseY)
            end
        | SECOND {x1, y1, x2, y2} =>
            let
              val model = AppType.addTriangleAndResetStage
                (model, x1, y1, x2, y2, hpos, vpos)

              val drawVec = getTrianglesVector model
              val drawMsg = DRAW_TRIANGLES_AND_RESET_BUTTONS drawVec
            in
              (model, drawMsg, mouseX, mouseY)
            end
      else
        (model, NO_DRAW, mouseX, mouseY)
    end

  fun resizeWindow (model, mouseX, mouseY, width, height) =
    let
      val model = AppType.withWindowResize (model, width, height)
      val triangles = getTrianglesVector model
      val graphLines = #graphLines model
      val drawMsg =
        RESIZE_TRIANGLES_BUTTONS_AND_GRAPH
          {triangles = triangles, graphLines = graphLines}
    in
      (model, drawMsg, mouseX, mouseY)
    end

  fun update (model: app_type, mouseX, mouseY, inputMsg) =
    case inputMsg of
      MOUSE_MOVE {x = mouseX, y = mouseY} =>
        mouseMoveOrRelease (model, mouseX, mouseY)
    | MOUSE_LEFT_RELEASE => mouseMoveOrRelease (model, mouseX, mouseY)
    | MOUSE_LEFT_CLICK => mouseLeftClick (model, mouseX, mouseY)
    | RESIZE_WINDOW {width, height} =>
        resizeWindow (model, mouseX, mouseY, width, height)
end
