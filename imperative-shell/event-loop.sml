structure EventLoop =
struct
  open CML
  open DrawMessage

  local
    fun loop (inputMailbox, drawMailbox, mouseX, mouseY, model) =
      let
        val inputMsg = Mailbox.recv inputMailbox
        val (model, drawMsg, mouseX, mouseY) =
          AppUpdate.update (model, mouseX, mouseY, inputMsg)
        val _ = Mailbox.send (drawMailbox, drawMsg)
      in
        loop (inputMailbox, drawMailbox, mouseX, mouseY, model)
      end
  in
    fun update (inputMailbox, drawMailbox) =
      loop (inputMailbox, drawMailbox, 0, 0, AppType.initial)
  end

  fun draw
    (drawMailbox, window, graphDrawObject, buttonDrawObject, buttonDrawLength) =
    if not (Glfw.windowShouldClose window) then
      case Mailbox.recvPoll drawMailbox of
        NONE =>
          let
            val _ = Gles3.clearColor (1.0, 1.0, 1.0, 1.0)
            val _ = Gles3.clear ()

            val _ = AppDraw.drawGraphLines graphDrawObject
            val _ = AppDraw.drawButton (buttonDrawObject, buttonDrawLength)

            val _ = Glfw.pollEvents ()
            val _ = Glfw.swapBuffers window
          in
            draw
              ( drawMailbox
              , window
              , graphDrawObject
              , buttonDrawObject
              , buttonDrawLength
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
                   , buttonDrawObject
                   , buttonDrawLength
                   )
               end
           | NO_DRAW =>
               draw
                 ( drawMailbox
                 , window
                 , graphDrawObject
                 , buttonDrawObject
                 , buttonDrawLength
                 ))
    else
      Glfw.terminate ()
end
