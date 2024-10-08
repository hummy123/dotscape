signature FILE_THREAD =
sig
  val run: FileMessage.t Mailbox.mbox * InputMessage.t Mailbox.mbox -> unit
end

structure FileThread :> FILE_THREAD =
struct
  open FileMessage
  open InputMessage

  datatype parse_result = OK of AppType.triangle list | PARSE_ERROR

  val structureName = "UnknownChar"
  val filename = "fonts/unknown-char.dsc"
  val exportFilename = "fonts/unknown-char.sml"

  fun ndcToLerpX num =
    let
      val num = (num + 1.0) / 2.0
      val num = Real32.toString num
      val num =
        (* Problem: It seems that Real32.toString may sometimes return a string
         * that is recognised as an integer, like "1" instead of "1.0".
         * If that happens, we just add a ".0" to the end 
         * so it's recognised as a real. *)
        if String.isSubstring "." num then num
        else num ^ ".0"
    in
      "      (((startX * (1.0 - " ^ num ^ ")) + (endX * " ^ num
      ^ ")) / windowWidth) - 1.0"
    end

  fun ndcToLerpY num =
    let
      val num = (num + 1.0) / 2.0
      val num = Real32.toString num
      val num = if String.isSubstring "." num then num else num ^ ".0"
    in
      "      (((startY * (1.0 - " ^ num ^ ")) + (endY * " ^ num
      ^ ")) / windowHeight) - 1.0"
    end

  fun helpExportTriangles (io, triangles) =
    case triangles of
      {x1, y1, x2, y2, x3, y3} :: tl =>
        let
          val x1 = ndcToLerpX x1
          val x2 = ndcToLerpX x2
          val x3 = ndcToLerpX x3

          val y1 = ndcToLerpY y1
          val y2 = ndcToLerpY y2
          val y3 = ndcToLerpY y3

          val line = String.concat
            [ x1
            , ",\n"
            , y1
            , ", r, g, b,\n"
            , x2
            , ",\n"
            , y2
            , ", r, g, b,\n"
            , x3
            , ",\n"
            , y3
            , case tl of
                [] => ", r, g, b\n"
              | _ => ", r, g, b,\n"
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
        "  fun lerp (startX, startY, drawWidth, drawHeight, windowWidth, windowHeight, r, g, b) : Real32.real vector =\n\
           \    let\n\
           \       val startX = Real32.fromInt startX\n\
           \       val startY = Real32.fromInt startY\n\
           \       val endY = windowHeight - startY\n\
           \       val startY = windowHeight - (startY + drawHeight)\n\
           \       val endX = startX + drawWidth\n\
           \       val windowHeight = windowHeight / 2.0\n\
           \       val windowWidth = windowWidth / 2.0\n\
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

  fun loadTriangles (path, inputMailbox) =
    let
      val io = TextIO.openIn path
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
            [ "x "
            , Real32.toString x1
            , " y "
            , Real32.toString y1

            , " x "
            , Real32.toString x2
            , " y "
            , Real32.toString y2

            , " x "
            , Real32.toString x3
            , " y "
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

  fun getDirList (dir, acc, rootPath) =
    case OS.FileSys.readDir dir of
      SOME path =>
        let
          val folderPath = String.concat [rootPath, "/", path]
        in
          if OS.FileSys.isDir folderPath then
            getDirList (dir, AppType.IS_FOLDER path :: acc, rootPath)
          else if OS.FileSys.isLink folderPath then
            getDirList (dir, acc, rootPath)
          else
            getDirList (dir, AppType.IS_FILE path :: acc, rootPath)
        end
    | NONE => let val acc = List.rev acc in Vector.fromList acc end

  fun loadFiles (path, inputMailbox) =
    let
      val path = if String.size path = 0 then OS.FileSys.getDir () else path
      val dir = OS.FileSys.openDir path
      val dirList = getDirList (dir, [], path)
      val _ = OS.FileSys.closeDir dir
      val inputMsg = FILE_BROWSER_AND_PATH {fileBrowser = dirList, path = path}
    in
      Mailbox.send (inputMailbox, inputMsg)
    end

  fun selectPath (path, inputMailbox) =
    if OS.FileSys.isDir path then loadFiles (path, inputMailbox)
    else loadTriangles (path, inputMailbox)

  fun run (fileMailbox, inputMailbox) =
    let
      val _ =
        case Mailbox.recv fileMailbox of
          SAVE_TRIANGLES triangles => saveTriangles triangles
        | LOAD_TRIANGLES => loadTriangles (filename, inputMailbox)
        | EXPORT_TRIANGLES triangles => exportTriangles triangles
        | LOAD_FILES path => loadFiles (path, inputMailbox)
        | SELECT_PATH path => selectPath (path, inputMailbox)
    in
      run (fileMailbox, inputMailbox)
    end
end
