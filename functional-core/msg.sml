signature MSG =
sig
  datatype t =
    MOUSE_MOVE of {x: int, y: int}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
end

structure Msg :> MSG =
struct
  datatype t =
    MOUSE_MOVE of {x: int, y: int}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
end
