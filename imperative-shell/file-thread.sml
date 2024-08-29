signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open AppType
  open FileMessage

  val filename = "a.dsc"

  datatype triangle_token = X | Y | COORD of Real32.real | UNKNOWN

  fun extractTriangle lst =
    case lst of
      [ X, COORD x1
      , Y, COORD y1
      , X, COORD x2

      , Y, COORD y2
      , X, COORD x3
      , Y, COORD y3
      ] => SOME {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
    | _ => NONE

  fun tokeniseString str =
    if str = "x" then
      X
    else if str = "y" then
      Y
    else
      case Real32.fromString str of
        SOME num => COORD num
      | NONE => UNKNOWN

  fun helpParseLine (line, pos, acc, lastSpacePos) =
    if pos = String.size line then
      List.rev acc
    else
      let
        val chr = String.sub (line, pos)
      in
        if chr = #" " orelse chr = #"\n" then
          let
            val strToken = String.substring
              (line, lastSpacePos + 1, pos - (lastSpacePos + 1))
            val token = tokeniseString strToken
          in
            helpParseLine (line, pos + 1, token :: acc, pos)
          end
        else
          helpParseLine (line, pos + 1, acc, lastSpacePos)
      end

  fun parseLine line =
    let val lst = helpParseLine (line, 0, [], ~1)
    in extractTriangle lst
    end

  datatype parse_resule = OK of AppType.triangle list | PARSE_ERROR

  fun parse (io, acc) =
    case TextIO.inputLine io of
      SOME line =>
        let
          val line = parseLine line
        in
          (case line of
             SOME tri => parse (io, tri :: acc)
           | NONE => PARSE_ERROR)
        end
    | NONE => let val triangles = List.rev acc in OK triangles end

  fun loadTriangles () =
    let
      val io = TextIO.openIn filename
      val triangles = parse (io, [])
      val _ = TextIO.closeIn io
    in
      case triangles of
        OK triangles => print "parse success\n"
      | PARSE_ERROR => print "parse error\n"
    end

  fun helpSaveTriangles (triangles, io) =
    case triangles of
      {x1, y1, x2, y2, x3, y3} :: tl =>
        let
          val triString = String.concat
            [ "x " , Real32.toString x1
            , " y " , Real32.toString y1

            , " x " , Real32.toString x2
            , " y " , Real32.toString y2

            , " x " , Real32.toString x3
            , " y " , Real32.toString y3
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
        | LOAD_TRIANGLES => loadTriangles ()
        | EXPORT_TRIANGLES triangles => ()
    in
      run fileMailbox
    end
end
