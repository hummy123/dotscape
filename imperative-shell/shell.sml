structure Shell =
struct
  open CML

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
      val _ = CML.spawn (fn () => EventLoop.update inputMailbox)
    in
      EventLoop.draw (window, graphDrawObject, buttonDrawObject, 0)
    end
end

val _ = RunCML.doit (Shell.main, NONE)
