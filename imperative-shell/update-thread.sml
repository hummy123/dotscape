signature UPDATE_THREAD =
sig
  val run:
      InputMessage.t Mailbox.mbox
    * DrawMessage.t Mailbox.mbox
    * FileMessage.t Mailbox.mbox
    * AppType.app_type
    -> unit
end

structure UpdateThread :> UPDATE_THREAD =
struct
  open CML
  open UpdateMessage

  fun handleMsg (drawMailbox, fileMailbox, updateMsg) =
    case updateMsg of
      DRAW drawMsg => Mailbox.send (drawMailbox, drawMsg)
    | FILE fileMsg => Mailbox.send (fileMailbox, fileMsg)
    | NO_MAILBOX => ()

  fun loop (inputMailbox, drawMailbox, fileMailbox, model) =
    let
      val inputMsg = Mailbox.recv inputMailbox
      val (model, updateMsg) = AppUpdate.update (model, inputMsg)
      val _ = handleMsg (drawMailbox, fileMailbox, updateMsg)
    in
      loop (inputMailbox, drawMailbox, fileMailbox, model)
    end

  fun run (inputMailbox, drawMailbox, fileMailbox, initial) =
    loop (inputMailbox, drawMailbox, fileMailbox, initial)
end
