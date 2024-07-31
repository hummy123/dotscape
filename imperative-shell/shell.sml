structure Shell =
struct
  open CML

  fun callbackListener mailbox =
    let
      open InputMessage
      val _ =
        case Mailbox.recv mailbox of
          MOUSE_MOVE {x, y} =>
            print (String.concat
              ["x pos: ", Int.toString x, ", y pos: ", Int.toString y, "\n"])
        | MOUSE_LEFT_CLICK => print "clicked mouse\n"
        | MOUSE_LEFT_RELEASE => print "released mouse\n"
    in
      callbackListener mailbox
    end

  fun loop (window, graphDrawObject, buttonDrawObject) =
    if not (Glfw.windowShouldClose window) then
      let
        val _ = Gles3.clearColor (1.0, 1.0, 1.0, 1.0)
        val _ = Gles3.clear ()

        val _ = AppDraw.drawGraphLines graphDrawObject
        val _ = AppDraw.drawButton (buttonDrawObject, #[])

        val _ = Glfw.pollEvents ()
        val _ = Glfw.swapBuffers window
      in
        loop (window, graphDrawObject, buttonDrawObject)
      end
    else
      Glfw.terminate ()

  fun main () =
    let
      (* Set up GLFW. *)
      val _ = Glfw.init ()
      val _ = Glfw.windowHint (Glfw.CONTEXT_VERSION_MAJOR (), 3)
      val _ = Glfw.windowHint (Glfw.DEPRECATED (), Glfw.FALSE ())
      val _ = Glfw.windowHint (Glfw.SAMPLES (), 4)
      val window = Glfw.createWindow (500, 500, "MLton - box x box")
      val _ = Glfw.makeContextCurrent window
      val _ = Gles3.loadGlad ()

      val graphDrawObject = AppDraw.initGraphLines ()
      val buttonDrawObject = AppDraw.initButton ()

      val inputMailbox = Mailbox.mailbox ()
      (* Set callback sender *)
      val _ = CML.spawn (fn () =>
        let
          val mouseMoveCallback = InputCallbacks.mouseMoveCallback inputMailbox
          val _ = Input.exportMouseMoveCallback mouseMoveCallback
          val _ = Input.setMouseMoveCallback window

          val mouseClickCallback =
            InputCallbacks.mouseClickCallback inputMailbox
          val _ = Input.exportMouseClickCallback mouseClickCallback
          val _ = Input.setMouseClickCallback window
        in
          ()
        end)
      (* Set callback listener *)
      val _ = CML.spawn (fn () => callbackListener inputMailbox)
    in
      loop (window, graphDrawObject, buttonDrawObject)
    end
end

val _ = RunCML.doit (Shell.main, NONE)
