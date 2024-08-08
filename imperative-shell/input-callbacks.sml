structure InputCallbacks =
struct
  open CML
  open InputMessage

  fun mouseMoveCallback mailbox (x, y) =
    Mailbox.send (mailbox, (MOUSE_MOVE {x = x, y = y}))

  fun mouseClickCallback mailbox (button, action) =
    if button = Input.LEFT_MOUSE_BUTTON () then
      if action = Input.PRESS () then Mailbox.send (mailbox, MOUSE_LEFT_CLICK)
      else Mailbox.send (mailbox, MOUSE_LEFT_RELEASE)
    else
      ()

  fun framebufferSizeCallback mailbox (width, height) =
    let val _ = Gles3.viewport (width, height)
    in Mailbox.send (mailbox, RESIZE_WINDOW {width = width, height = height})
    end

  fun keyActionCallback mailbox (key, scancode, action, mods) =
    if
      key = Input.KEY_Z () andalso action <> Input.RELEASE ()
      andalso mods = 0x0002
    then Mailbox.send (mailbox, UNDO_ACTION)
    else ()

  fun registerCallbacks (window, inputMailbox) =
    let
      val mouseMoveCallback = mouseMoveCallback inputMailbox
      val _ = Input.exportMouseMoveCallback mouseMoveCallback
      val _ = Input.setMouseMoveCallback window

      val mouseClickCallback = mouseClickCallback inputMailbox
      val _ = Input.exportMouseClickCallback mouseClickCallback
      val _ = Input.setMouseClickCallback window

      val resizeCallback = framebufferSizeCallback inputMailbox
      val _ = Input.exportFramebufferSizeCallback resizeCallback
      val _ = Input.setFramebufferSizeCallback window

      val keyCallback = keyActionCallback inputMailbox
      val _ = Input.exportKeyCallback keyCallback
      val _ = Input.setKeyCallback window
    in
      ()
    end
end
