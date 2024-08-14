structure EventLoop =
struct
  open CML
  open DrawMessage

  local
    fun loop (inputMailbox, drawMailbox, model) =
      let
        val inputMsg = Mailbox.recv inputMailbox
        val (model, drawMsg) = AppUpdate.update (model, inputMsg)
        val _ = Mailbox.send (drawMailbox, drawMsg)
      in
        loop (inputMailbox, drawMailbox, model)
      end
  in
    fun update (inputMailbox, drawMailbox, initial) =
      loop (inputMailbox, drawMailbox, initial)
  end

  fun draw
    ( drawMailbox
    , window
    , graphDrawObject
    , drawGraphLength
    , buttonDrawObject
    , buttonDrawLength
    , triangleDrawObject
    , triangleDrawLength
    ) =
    if not (Glfw.windowShouldClose window) then
      case Mailbox.recvPoll drawMailbox of
        NONE =>
          let
            val _ = Gles3.clearColor (1.0, 1.0, 1.0, 1.0)
            val _ = Gles3.clear ()

            val _ = AppDraw.drawGraphLines (graphDrawObject, drawGraphLength)
            val _ =
              AppDraw.drawTriangles (triangleDrawObject, triangleDrawLength)
            val _ = AppDraw.drawButton (buttonDrawObject, buttonDrawLength)

            val _ = Glfw.swapBuffers window
            val _ = Glfw.pollEvents ()
          in
            draw
              ( drawMailbox
              , window
              , graphDrawObject
              , drawGraphLength
              , buttonDrawObject
              , buttonDrawLength
              , triangleDrawObject
              , triangleDrawLength
              )
          end
      | SOME drawMsg =>
          (case drawMsg of
             DRAW_BUTTON vec =>
               let
                 val _ = AppDraw.uploadButtonVector (buttonDrawObject, vec)
                 val buttonDrawLength = Vector.length vec div 5
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , buttonDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | DRAW_TRIANGLES_AND_RESET_BUTTONS triangleVec =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector
                     (triangleDrawObject, triangleVec)
                 val triangleDrawLength = Vector.length triangleVec div 2
               (* buttons are reset by setting buttonDrawLength to 0 *)
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , 0
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | DRAW_TRIANGLES_AND_BUTTONS
               {triangles = triangleVec, buttons = buttonsVec} =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector
                     (triangleDrawObject, triangleVec)
                 val triangleDrawLength = Vector.length triangleVec div 2

                 val _ =
                   AppDraw.uploadButtonVector (buttonDrawObject, buttonsVec)
                 val buttonDrawLength = Vector.length buttonsVec div 5
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , buttonDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | CLEAR_BUTTONS =>
               let
                 val buttonDrawLength = 0
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , buttonDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | RESIZE_TRIANGLES_BUTTONS_AND_GRAPH {triangles, graphLines} =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector (triangleDrawObject, triangles)
                 val triangleDrawLength = Vector.length triangles div 2
                 (* buttons are reset by setting buttonDrawLength to 0 *)
                 val _ = AppDraw.uploadGraphLines (graphDrawObject, graphLines)
                 val drawGraphLength = Vector.length graphLines div 2
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , 0
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | DRAW_GRAPH graphLines =>
               let
                 val _ = AppDraw.uploadGraphLines (graphDrawObject, graphLines)
                 val drawGraphLength = Vector.length graphLines div 2
               in
                 draw
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , buttonDrawObject
                   , buttonDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   )
               end
           | NO_DRAW =>
               draw
                 ( drawMailbox
                 , window
                 , graphDrawObject
                 , drawGraphLength
                 , buttonDrawObject
                 , buttonDrawLength
                 , triangleDrawObject
                 , triangleDrawLength
                 ))
    else
      Glfw.terminate ()
end
