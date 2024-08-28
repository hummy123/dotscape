signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open AppType
  open FileMessage

  val filename = "a.dsc"

  fun helpSaveTriangles (triangles, io) =
    case triangles of
      {x1, y1, x2, y2, x3, y3} :: tl =>
        let
          val triString = String.concat
            [ "x1:"
            , Real32.toString x1
            , " y1:"
            , Real32.toString y1

            , " x2:"
            , Real32.toString x2
            , " y2:"
            , Real32.toString y2

            , " x3:"
            , Real32.toString x3
            , " y3:"
            , Real32.toString y3
            , "\n"
            ]

          val _ = TextIO.output (io, triString)
        in
          helpSaveTriangles (tl, io)
        end
    | [] => ()

  fun saveTriangles triangles =
    let
      val io = TextIO.openOut filename
      val _ = helpSaveTriangles (triangles, io)
      val _ = TextIO.closeOut io
    in
      ()
    end

  fun run fileMailbox =
    let
      val _ =
        case Mailbox.recv fileMailbox of
          SAVE_TRIANGLES triangles => saveTriangles triangles
        | LOAD_TRIANGLES => ()
        | EXPORT_TRIANGLES triangles => ()
    in
      run fileMailbox
    end
end
