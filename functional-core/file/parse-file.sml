signature PARSE_FILE =
sig
  val parseLine: string -> AppType.triangle option
end

structure ParseFile :> PARSE_FILE =
struct
  datatype triangle_token = X | Y | COORD of Real32.real | UNKNOWN of string

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
      | NONE => UNKNOWN str

  fun helpParseLine (line, pos, acc, wordStartPos) =
    if pos = String.size line then
      List.rev acc
    else
      let
        val chr = String.sub (line, pos)
      in
        if Char.isSpace chr then
          if pos > 0 andalso Char.isSpace (String.sub (line, pos - 1)) then
            (* if previous character is space, just proceed to next character *)
            helpParseLine (line, pos + 1, acc, wordStartPos)
          else
            let
              (* current character is space, but previous character is not, 
               * which means we have some text to substring and tokenise 
               * before proceeding to next character *)
              val strToken =
                String.substring (line, wordStartPos, pos - wordStartPos)
              val token = tokeniseString strToken
            in
              helpParseLine (line, pos + 1, token :: acc, pos)
            end
        else if pos > 0 andalso Char.isSpace (String.sub (line, pos - 1)) then
          (* previous character was space but current character is not,
           * meaning that we have hit the start of a new word *)
          helpParseLine (line, pos + 1, acc, pos)
        else
          (* just proceed to next character *)
          helpParseLine (line, pos + 1, acc, wordStartPos)
      end

  fun parseLine line =
    let
      val lst = helpParseLine (line, 0, [], 0)
    in
      extractTriangle lst
    end
end
