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

  type app_type = {triangleStage: triangle_stage, triangles: triangle list}

  val initial: app_type

  val withTriangleStage: app_type * triangle_stage -> app_type

  val addTriangleAndResetStage : 
    app_type *
    Real32.real *
    Real32.real *
    Real32.real *
    Real32.real *
    Real32.real *
    Real32.real ->
    app_type
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

  type app_type = {triangles: triangle list, triangleStage: triangle_stage}

  val initial = {triangles = [], triangleStage = NO_TRIANGLE}

  fun withTriangleStage (app: app_type, newTriangleStage: triangle_stage) :
    app_type =
    let val {triangles, triangleStage = _} = app
    in {triangles = triangles, triangleStage = newTriangleStage}
    end

  fun addTriangleAndResetStage (app: app_type, x1, y1, x2, y2, x3, y3) :
    app_type =
    let
      val {triangles, triangleStage = _} = app

      val newTriangle = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, x3 = x3, y3 = y3}
      val newTriangles = newTriangle :: triangles
    in
      {triangles = newTriangles, triangleStage = NO_TRIANGLE}
    end
end
