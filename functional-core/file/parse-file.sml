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
end
