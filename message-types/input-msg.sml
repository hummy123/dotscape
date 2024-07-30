signature INPUT_MESSAGE =
sig
  datatype t =
    MOUSE_MOVE of {x: int, y: int}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
end

structure InputMessage :> INPUT_MESSAGE =
struct
  datatype t =
    MOUSE_MOVE of {x: int, y: int}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
end
