signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open FileMessage

  fun run fileMailbox =
    let
      val _ =
        case Mailbox.recv fileMailbox of
          SAVE_TRIANGLES triangles => ()
        | EXPORT_TRIANGLES triangles => ()
        | IMPORT_TRIANGLES => ()
    in
      run fileMailbox
    end
end
