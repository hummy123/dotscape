signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox * InputMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open FileMessage
  open InputMessage

  datatype parse_result = OK of AppType.triangle list | PARSE_ERROR

  val structureName = "LowerCaseA"
  val filename = "a.dsc"
  val exportFilename = "a.sml"

  datatype dir = X | Y

  fun ndcToLerp (num, dir) =
    let
      val num = (num + 1.0) / 2.0
      val num = Real32.toString num
    in
      case dir of
        X =>
          "      ((startX * (1.0 - " ^ num ^ ")) + (endX * " ^ num ^ ")) / windowWidth"
      | Y =>
          "      ((startY * (1.0 - " ^ num ^ ")) + (endY * " ^ num ^ ")) / windowHeight"
    end

  fun helpExportTriangles (io, triangles) =
    case triangles of
      {x1, y1, x2, y2, x3, y3} :: tl =>
        let
          val x1 = ndcToLerp (x1, X)
          val x2 = ndcToLerp (x2, X)
          val x3 = ndcToLerp (x3, X)

          val y1 = ndcToLerp (y1, Y)
          val y2 = ndcToLerp (y2, Y)
          val y3 = ndcToLerp (y3, Y)

          val line = String.concat
            [ x1, ",\n", y1, ",\n"
            , x2, ",\n", y2, ",\n"
            , x3, ",\n", y3
            , case tl of [] => "\n" | _ => ",\n"
            ]

          val _ = TextIO.output (io, line)
        in
          helpExportTriangles (io, tl)
        end
    | [] => ()

  fun exportTriangles triangles =
    let
      val io = TextIO.openOut exportFilename

      val fileStartString =
        String.concat ["structure ", structureName, " =\nstruct\n"]
      val _ = TextIO.output (io, fileStartString)

      val functionStartString =
        "  fun lerp (startX, startY, drawWidth, drawHeight, windowWidth, windowHeight) : Real32.real vector =\n\
           \    let\n\
           \       val startX = Real32.fromInt startX\n\
           \       val startY = Real32.fromInt startY\n\
           \       val endX = startX + drawWidth\n\
           \       val endY = startY + drawHeight\n\
           \    in\n\
           \       #["
      val _ = TextIO.output (io, functionStartString)

      val _ = helpExportTriangles (io, triangles)

      val _ = TextIO.output (io, "    ]\n  end\nend")
      val _ = TextIO.closeOut io
    in
      ()
    end

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
        | EXPORT_TRIANGLES triangles => exportTriangles triangles
    in
      run (fileMailbox, inputMailbox)
    end
end
