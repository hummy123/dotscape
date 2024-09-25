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
    then
      if mods = 0x0002 then
        (* ctrl-z *)
        Mailbox.send (mailbox, UNDO_ACTION)
      else if mods = 0x0003 then
        (* ctrl-shift-z *)
        Mailbox.send (mailbox, REDO_ACTION)
      else
        (* no action recognised *)
        ()
    else if
      (* ctrl-y *)
      key = Input.KEY_Y () andalso action <> Input.RELEASE ()
      andalso mods = 0x0002
    then
      Mailbox.send (mailbox, REDO_ACTION)
    else if
      key = Input.KEY_G () andalso action <> Input.RELEASE () andalso mods = 0x0
    then
      Mailbox.send (mailbox, KEY_G)
    else if
      (* ctrl-s *)
      key = Input.KEY_S () andalso action = Input.PRESS () andalso mods = 0x002
    then
      Mailbox.send (mailbox, KEY_CTRL_S)
    else if
      (* ctrl-l *)
      key = Input.KEY_L () andalso action = Input.PRESS () andalso mods = 0x002
    then
      Mailbox.send (mailbox, KEY_CTRL_L)
    else if
      (* ctrl-l *)
      key = Input.KEY_E () andalso action = Input.PRESS () andalso mods = 0x002
    then
      Mailbox.send (mailbox, KEY_CTRL_E)
    else if
      key = Input.KEY_UP () andalso action <> Input.RELEASE ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, ARROW_UP)
    else if
      key = Input.KEY_LEFT () andalso action <> Input.RELEASE ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, ARROW_LEFT)
    else if
      key = Input.KEY_RIGHT () andalso action <> Input.RELEASE ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, ARROW_RIGHT)
    else if
      key = Input.KEY_DOWN () andalso action <> Input.RELEASE ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, ARROW_DOWN)
    else if
      key = Input.KEY_ENTER () andalso action = Input.PRESS ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, KEY_ENTER)
    else if
      key = Input.KEY_SPACE () andalso action = Input.PRESS ()
      andalso mods = 0x0
    then
      Mailbox.send (mailbox, KEY_SPACE)
    else if
      key = Input.KEY_O () andalso action = Input.PRESS () andalso mods = 0x02
    then
      Mailbox.send (mailbox, KEY_CTRL_O)
    else
      ()

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
