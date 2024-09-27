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

  fun handleMsgs (drawMailbox, fileMailbox, lst) =
    case lst of
      hd :: tl =>
        let val _ = handleMsg (drawMailbox, fileMailbox, hd)
        in handleMsgs (drawMailbox, fileMailbox, tl)
        end
    | [] => ()

  fun loop (inputMailbox, drawMailbox, fileMailbox, model) =
    let
      val inputMsg = Mailbox.recv inputMailbox
      val (model, updateMsgs) = AppUpdate.update (model, inputMsg)
      val _ = handleMsgs (drawMailbox, fileMailbox, updateMsgs)
    in
      loop (inputMailbox, drawMailbox, fileMailbox, model)
    end

  fun run (inputMailbox, drawMailbox, fileMailbox, initial) =
    loop (inputMailbox, drawMailbox, fileMailbox, initial)
end
