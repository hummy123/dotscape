structure Input =
struct
  type window = MLton.Pointer.t

  (* Export function to C. *)
  val exportMouseMoveCallback =
    _export "mltonMouseMoveCallback" public : (Real32.real * Real32.real -> unit) -> unit;

  (* Import function to set callback for GLFW. *)
  val setMouseMoveCallback = _import "setMouseMoveCallback" public reentrant : window -> unit;

  val exportMouseClickCallback =
    _export "mltonMouseClickCallback" public : (int * int -> unit) -> unit;
  val setMouseClickCallback = _import "setMouseClickCallback" public reentrant : window -> unit;

  val exportFramebufferSizeCallback =
    _export "mltonFramebufferSizeCallback" public : (int * int -> unit) -> unit;
  val setFramebufferSizeCallback = 
    _import "setFramebufferSizeCallback" public reentrant : window -> unit;

  (* Constants for mouse input. *)
  val (MOUSE_PRESSED, _) =
    _symbol "MOUSE_PRESSED" public : ( unit -> int ) * ( int -> unit );
  val (MOUSE_RELEASED, _) =
    _symbol "MOUSE_RELEASED" public : ( unit -> int ) * ( int -> unit );
  val (LEFT_MOUSE_BUTTON, _) =
    _symbol "LEFT_MOUSE_BUTTON" public : ( unit -> int ) * ( int -> unit );
end
