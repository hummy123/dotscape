signature DRAW_MESSAGE =
sig
  datatype t =
    DRAW_DOT of Real32.real vector
  | DRAW_TRIANGLES_AND_DOTS of
      {triangles: Real32.real vector, dots: Real32.real vector}
  | DRAW_TRIANGLES_AND_RESET_DOTS of Real32.real vector
  | DRAW_GRAPH of Real32.real vector
  | RESIZE_TRIANGLES_DOTS_AND_GRAPH of
      { triangles: Real32.real vector
      , graphLines: Real32.real vector
      , dots: Real32.real vector
      }
  | CLEAR_DOTS
  | DRAW_MODAL_TEXT of Real32.real vector
end

structure DrawMessage :> DRAW_MESSAGE =
struct
  datatype t =
    DRAW_DOT of Real32.real vector
  | DRAW_TRIANGLES_AND_DOTS of
      {triangles: Real32.real vector, dots: Real32.real vector}
  | DRAW_TRIANGLES_AND_RESET_DOTS of Real32.real vector
  | DRAW_GRAPH of Real32.real vector
  | RESIZE_TRIANGLES_DOTS_AND_GRAPH of
      { triangles: Real32.real vector
      , graphLines: Real32.real vector
      , dots: Real32.real vector
      }
  | CLEAR_DOTS
  | DRAW_MODAL_TEXT of Real32.real vector
end
