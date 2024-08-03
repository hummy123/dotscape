signature DRAW_MESSAGE =
sig
  datatype t =
    DRAW_BUTTON of Real32.real vector
  | DRAW_TRIANGLES_AND_RESET_BUTTONS of Real32.real vector
  | RESIZE_TRIANGLES_BUTTONS_AND_GRAPH of
      {triangles: Real32.real vector, graphLines: Real32.real vector}
  | NO_DRAW
end

structure DrawMessage :> DRAW_MESSAGE =
struct
  datatype t =
    DRAW_BUTTON of Real32.real vector
  | DRAW_TRIANGLES_AND_RESET_BUTTONS of Real32.real vector
  | RESIZE_TRIANGLES_BUTTONS_AND_GRAPH of
      {triangles: Real32.real vector, graphLines: Real32.real vector}
  | NO_DRAW
end
