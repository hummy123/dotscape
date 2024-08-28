signature UPDATE_THREAD =
sig
  val run:
      InputMessage.t Mailbox.mbox
    * DrawMessage.t Mailbox.mbox
    * AppType.app_type
    -> unit
end

structure UpdateThread :> UPDATE_THREAD =
struct
  open CML
  open UpdateMessage

  fun handleMsg (drawMailbox, updateMsg) =
    case updateMsg of
      DRAW drawMsg => Mailbox.send (drawMailbox, drawMsg)
    | FILE fileMsg => ()
    | NO_MAILBOX => ()

  fun loop (inputMailbox, drawMailbox, model) =
    let
      val inputMsg = Mailbox.recv inputMailbox
      val (model, updateMsg) = AppUpdate.update (model, inputMsg)
      val _ = handleMsg (drawMailbox, updateMsg)
    in
      loop (inputMailbox, drawMailbox, model)
    end

  fun run (inputMailbox, drawMailbox, initial) =
    loop (inputMailbox, drawMailbox, initial)
end
