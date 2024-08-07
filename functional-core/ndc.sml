structure Ndc = 
struct
  (* ndc = normalised device coordinates *)

  fun ltrbToVertex (left, top, right, bottom, r, g, b) =
    #[ left, bottom, r, g, b
     , right, bottom, r, g, b
     , left, top, r, g, b

     , left, top, r, g, b
     , right, bottom, r, g, b
     , right, top, r, g, b
     ]
end
