structure Shell =
struct
  open CML

  datatype msg = KEY of int * int * int * int

  fun keyCallback mailbox (key, scancode, action, mode) =
    ( print "hello\n"
    ; Mailbox.send (mailbox, (KEY (key, scancode, action, mode)))
    )

  fun callbackListener mailbox =
    let
      val _ =
        case Mailbox.recv mailbox of
          KEY (key, scancode, action, mode) =>
            print (String.concat
              [ "key: "
              , Int.toString key
              , " scancode: "
              , Int.toString scancode
              , " action: "
              , Int.toString action
              , " mode: "
              , Int.toString mode
              , "\n"
              ])
    in
      callbackListener mailbox
    end

  fun loop (window, graphDrawObject) =
    if not (Glfw.windowShouldClose window) then
      let
        val _ = Gles3.clearColor (1.0, 1.0, 1.0, 1.0)
        val _ = Gles3.clear ()

        val _ = AppDraw.drawGraphLines graphDrawObject

        val _ = Glfw.pollEvents ()
        val _ = Glfw.swapBuffers window
      in
        loop (window, graphDrawObject)
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

      val inputMailbox = Mailbox.mailbox ()
      (* Set callback sender *)
      val _ = CML.spawn (fn () =>
        let
          val kbCallback = keyCallback inputMailbox
          val _ = Key.export kbCallback
          val _ = Key.setCallback window
        in
          ()
        end)
      (* Set callback listener *)
      val _ = CML.spawn (fn () => callbackListener inputMailbox)
    in
      loop (window, graphDrawObject)
    end
end

val _ = RunCML.doit (Shell.main, NONE)
