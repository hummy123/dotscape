signature INPUT_MESSAGE =
sig
  datatype t =
    MOUSE_MOVE of {x: Real32.real, y: Real32.real}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
  | RESIZE_WINDOW of {width: int, height: int}
  | UNDO_ACTION
  | REDO_ACTION
  | KEY_G
  | KEY_CTRL_S
  | KEY_CTRL_L
  | KEY_CTRL_E
  | USE_TRIANGLES of AppType.triangle list
  | TRIANGLES_LOAD_ERROR
end

structure InputMessage :> INPUT_MESSAGE =
struct
  datatype t =
    MOUSE_MOVE of {x: Real32.real, y: Real32.real}
  | MOUSE_LEFT_CLICK
  | MOUSE_LEFT_RELEASE
  | RESIZE_WINDOW of {width: int, height: int}
  | UNDO_ACTION
  | REDO_ACTION
  | KEY_G
  | KEY_CTRL_S
  | KEY_CTRL_L
  | KEY_CTRL_E
  | USE_TRIANGLES of AppType.triangle list
  | TRIANGLES_LOAD_ERROR
end
