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
      val window =
        Glfw.createWindow
          (Constants.windowWidth, Constants.windowHeight, "Dotscape")
      val _ = Glfw.makeContextCurrent window
      val _ = Gles3.loadGlad ()

      val initialModel =
        AppInit.fromWindowWidthAndHeight
          (Constants.windowWidth, Constants.windowHeight)

      val graphLines = GraphLines.generate initialModel
      val graphDrawObject = AppDraw.initGraphLines ()
      val _ = AppDraw.uploadGraphLines (graphDrawObject, graphLines)

      val dotDrawObject = AppDraw.initDot ()
      val triangleDrawObject = AppDraw.initTriangles ()

      val inputMailbox = Mailbox.mailbox ()
      val drawMailbox = Mailbox.mailbox ()
      val fileMailbox = Mailbox.mailbox ()

      val _ = InputCallbacks.registerCallbacks (window, inputMailbox)

      val _ = CML.spawn (fn () =>
        UpdateThread.run (inputMailbox, drawMailbox, fileMailbox, initialModel))

      val _ = CML.spawn (fn () =>
        DrawThread.run
          ( drawMailbox
          , window
          , graphDrawObject
          , Vector.length graphLines div 2
          , dotDrawObject
          , 0
          , triangleDrawObject
          , 0
          ))

      val _ = CML.spawn (fn () => FileThread.run (fileMailbox, inputMailbox))
    in
      ()
    end
end

val _ = RunCML.doit (Shell.main, NONE)
