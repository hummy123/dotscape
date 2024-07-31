structure InputCallbacks =
struct
  open CML
  open InputMessage

  fun mouseMoveCallback mailbox (x, y) =
    Mailbox.send (mailbox, (MOUSE_MOVE {x = x, y = y}))

  fun mouseClickCallback mailbox (button, action) =
    if button = Input.LEFT_MOUSE_BUTTON () then
      if action = Input.MOUSE_PRESSED () then
        Mailbox.send (mailbox, MOUSE_LEFT_CLICK)
      else
        Mailbox.send (mailbox, MOUSE_LEFT_RELEASE)
    else
      ()

  fun registerCallbacks (window, inputMailbox) =
        let
          val mouseMoveCallback = mouseMoveCallback inputMailbox
          val _ = Input.exportMouseMoveCallback mouseMoveCallback
          val _ = Input.setMouseMoveCallback window

          val mouseClickCallback =
            mouseClickCallback inputMailbox
          val _ = Input.exportMouseClickCallback mouseClickCallback
          val _ = Input.setMouseClickCallback window
        in
          ()
        end
end
