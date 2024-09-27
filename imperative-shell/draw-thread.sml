structure DrawThread =
struct
  open CML
  open DrawMessage

  fun run
    ( drawMailbox
    , window
    , graphDrawObject
    , drawGraphLength
    , dotDrawObject
    , dotDrawLength
    , triangleDrawObject
    , triangleDrawLength
    , modalTextDrawObject
    , modalTextDrawLength
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
            val _ = AppDraw.drawDot (dotDrawObject, dotDrawLength)
            val _ =
              AppDraw.drawModalText (modalTextDrawObject, modalTextDrawLength)

            val _ = Glfw.swapBuffers window
            val _ = Glfw.pollEvents ()
          in
            run
              ( drawMailbox
              , window
              , graphDrawObject
              , drawGraphLength
              , dotDrawObject
              , dotDrawLength
              , triangleDrawObject
              , triangleDrawLength
              , modalTextDrawObject
              , modalTextDrawLength
              )
          end
      | SOME drawMsg =>
          (case drawMsg of
             DRAW_DOT vec =>
               let
                 val _ = AppDraw.uploadDotVector (dotDrawObject, vec)
                 val dotDrawLength = Vector.length vec div 5
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | DRAW_TRIANGLES_AND_RESET_DOTS triangleVec =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector
                     (triangleDrawObject, triangleVec)
                 val triangleDrawLength = Vector.length triangleVec div 2
               (* dots are reset by setting dotDrawLength to 0 *)
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , 0
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | DRAW_TRIANGLES_AND_DOTS {triangles = triangleVec, dots = dotsVec} =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector
                     (triangleDrawObject, triangleVec)
                 val triangleDrawLength = Vector.length triangleVec div 2

                 val _ = AppDraw.uploadDotVector (dotDrawObject, dotsVec)
                 val dotDrawLength = Vector.length dotsVec div 5
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | CLEAR_DOTS =>
               let
                 val dotDrawLength = 0
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | RESIZE_TRIANGLES_DOTS_AND_GRAPH {triangles, graphLines, dots} =>
               let
                 val _ =
                   AppDraw.uploadTrianglesVector (triangleDrawObject, triangles)
                 val triangleDrawLength = Vector.length triangles div 2

                 val _ = AppDraw.uploadGraphLines (graphDrawObject, graphLines)
                 val drawGraphLength = Vector.length graphLines div 2

                 val _ = AppDraw.uploadDotVector (dotDrawObject, dots)
                 val dotDrawLength = Vector.length dots div 5
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | DRAW_GRAPH graphLines =>
               let
                 val _ = AppDraw.uploadGraphLines (graphDrawObject, graphLines)
                 val drawGraphLength = Vector.length graphLines div 2
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end
           | DRAW_MODAL_TEXT vec =>
               let
                 val _ = AppDraw.uploadModalText (modalTextDrawObject, vec)
                 val modalTextDrawLength = Vector.length vec div 5
               in
                 run
                   ( drawMailbox
                   , window
                   , graphDrawObject
                   , drawGraphLength
                   , dotDrawObject
                   , dotDrawLength
                   , triangleDrawObject
                   , triangleDrawLength
                   , modalTextDrawObject
                   , modalTextDrawLength
                   )
               end)
    else
      Glfw.terminate ()
end
