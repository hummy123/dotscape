structure EventLoop =
struct
  open CML
  open InputMessage

  local
  fun loop (inputMailbox, drawMailbox, mouseX, mouseY, model) =
    let
      val inputMsg = Mailbox.recv inputMailbox
      val (model, drawMsg, mouseX, mouseY) = AppUpdate.update (model, mouseX, mouseY, inputMsg)
      val _ = Mailbox.send (drawMailbox, drawMsg)
    in
      loop (inputMailbox, drawMailbox, mouseX, mouseY, model)
    end
  in
    fun update (inputMailbox, drawMailbox) =
      loop (inputMailbox, drawMailbox, 0, 0, AppType.initial)
  end

  fun draw (window, graphDrawObject, buttonDrawObject, buttonDrawLength) =
    if not (Glfw.windowShouldClose window) then
      let
        val _ = Gles3.clearColor (1.0, 1.0, 1.0, 1.0)
        val _ = Gles3.clear ()

        val _ = AppDraw.drawGraphLines graphDrawObject
        val _ = AppDraw.drawButton (buttonDrawObject, buttonDrawLength)

        val _ = Glfw.pollEvents ()
        val _ = Glfw.swapBuffers window
      in
        draw (window, graphDrawObject, buttonDrawObject, buttonDrawLength)
      end
    else
      Glfw.terminate ()
end
