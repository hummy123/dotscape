structure EventLoop =
struct
  open CML
  open InputMessage

  fun update inputMailbox =
    let
      val _ =
        case Mailbox.recv inputMailbox of
          MOUSE_MOVE {x, y} =>
            print (String.concat
              ["x pos: ", Int.toString x, ", y pos: ", Int.toString y, "\n"])
        | MOUSE_LEFT_CLICK => print "clicked mouse\n"
        | MOUSE_LEFT_RELEASE => print "released mouse\n"
    in
      update inputMailbox
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
