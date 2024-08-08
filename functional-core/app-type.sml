signature APP_TYPE =
sig
  datatype triangle_stage =
    NO_TRIANGLE
  | FIRST of {x1: Real32.real, y1: Real32.real}
  | SECOND of
      {x1: Real32.real, x2: Real32.real, y1: Real32.real, y2: Real32.real}

  type triangle =
    { x1: Real32.real
    , x2: Real32.real
    , x3: Real32.real
    , y1: Real32.real
    , y2: Real32.real
    , y3: Real32.real
    }

  type app_type =
    { triangles: triangle list
    , triangleStage: triangle_stage
    , windowWidth: int
    , windowHeight: int
    , xClickPoints: Real32.real vector
    , yClickPoints: Real32.real vector
    , graphLines: Real32.real vector
    , undo: (Real32.real * Real32.real) list
    }
end

structure AppType :> APP_TYPE =
struct
  type triangle =
    { x1: Real32.real
    , y1: Real32.real
    , x2: Real32.real
    , y2: Real32.real
    , x3: Real32.real
    , y3: Real32.real
    }

  datatype triangle_stage =
    NO_TRIANGLE
  (* 
   * triangle_stage represents a work-in-progress triangle which is not fully completed,
   * because user has to click one (x, y) pair, then a second pair, 
   * and then a third, to draw a complete triangle.
   *
   * There is no THIRD triangle_stage because that represents a complete triangle, 
   * which should be added to the `triangles` list. 
   *)
  | FIRST of {x1: Real32.real, y1: Real32.real}
  | SECOND of
      {x1: Real32.real, y1: Real32.real, x2: Real32.real, y2: Real32.real}

  type app_type =
    { triangles: triangle list
    , triangleStage: triangle_stage
    , windowWidth: int
    , windowHeight: int
    , xClickPoints: Real32.real vector
    , yClickPoints: Real32.real vector
    , graphLines: Real32.real vector
    , undo: (Real32.real * Real32.real) list
    }
end
