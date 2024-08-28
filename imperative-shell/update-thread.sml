structure UpdateThread =
struct
  open CML

  local
    fun loop (inputMailbox, drawMailbox, model) =
      let
        val inputMsg = Mailbox.recv inputMailbox
        val (model, drawMsg) = AppUpdate.update (model, inputMsg)
        val _ = Mailbox.send (drawMailbox, drawMsg)
      in
        loop (inputMailbox, drawMailbox, model)
      end
  in
    fun run (inputMailbox, drawMailbox, initial) =
      loop (inputMailbox, drawMailbox, initial)
  end
end
