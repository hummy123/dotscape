signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox * InputMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open FileMessage
  open InputMessage

  datatype parse_result = OK of AppType.triangle list | PARSE_ERROR

  val filename = "a.dsc"

  fun parse (io, acc) =
    case TextIO.inputLine io of
      SOME line =>
        let
          val line = ParseFile.parseLine line
        in
          (case line of
             SOME tri => parse (io, tri :: acc)
           | NONE => PARSE_ERROR)
        end
    | NONE => let val triangles = List.rev acc in OK triangles end

  fun loadTriangles inputMailbox =
    let
      val io = TextIO.openIn filename
      val triangles = parse (io, [])
      val _ = TextIO.closeIn io

      val inputMsg =
        case triangles of
          OK triangles => USE_TRIANGLES triangles
        | PARSE_ERROR => TRIANGLES_LOAD_ERROR
    in
      Mailbox.send (inputMailbox, inputMsg)
    end

  fun helpSaveTriangles (triangles, io) =
    case triangles of
      {x1, y1, x2, y2, x3, y3} :: tl =>
        let
          val triString = String.concat
            [ "x ", Real32.toString x1
            , " y ", Real32.toString y1

            , " x ", Real32.toString x2
            , " y ", Real32.toString y2

            , " x ", Real32.toString x3
            , " y ", Real32.toString y3
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

  fun run (fileMailbox, inputMailbox) =
    let
      val _ =
        case Mailbox.recv fileMailbox of
          SAVE_TRIANGLES triangles => saveTriangles triangles
        | LOAD_TRIANGLES => loadTriangles inputMailbox
        | EXPORT_TRIANGLES triangles => ()
    in
      run (fileMailbox, inputMailbox)
    end
end
