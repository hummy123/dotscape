structure InputCallbacks =
struct
  open CML
  open Msg

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
end
