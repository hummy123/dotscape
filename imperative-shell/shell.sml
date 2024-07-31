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
      val drawMailbox = Mailbox.mailbox ()

      val _ = CML.spawn (fn () =>
        InputCallbacks.registerCallbacks (window, inputMailbox))
      val _ = CML.spawn (fn () => EventLoop.update (inputMailbox, drawMailbox))
      val _ = CML.spawn (fn () =>
        EventLoop.draw
          (drawMailbox, window, graphDrawObject, buttonDrawObject, 0))
    in
      ()
    end
end

val _ = RunCML.doit (Shell.main, NONE)
