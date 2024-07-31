signature DRAW_MESSAGE =
sig
  datatype t = DRAW_BUTTON of Real32.real vector
             | NO_DRAW
end

structure DrawMessage :> DRAW_MESSAGE =
struct 
  datatype t = DRAW_BUTTON of Real32.real vector 
             | NO_DRAW
end
