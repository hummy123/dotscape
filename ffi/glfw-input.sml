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
  val (PRESS, _) =
    _symbol "PRESS" public : ( unit -> int ) * ( int -> unit );
  val (RELEASE, _) =
    _symbol "RELEASE" public : ( unit -> int ) * ( int -> unit );
  val (LEFT_MOUSE_BUTTON, _) =
    _symbol "LEFT_MOUSE_BUTTON" public : ( unit -> int ) * ( int -> unit );

  (* Key input *)
  val exportKeyCallback =
    _export "mltonKeyCallback" public : (int * int * int * int -> unit) -> unit;
  val setKeyCallback = _import "setKeyCallback" public reentrant : window -> unit;

  val (KEY_G, _) =
    _symbol "KEY_G" public : ( unit -> int ) * ( int -> unit );
  val (KEY_Y, _) =
    _symbol "KEY_Y" public : ( unit -> int ) * ( int -> unit );
  val (KEY_Z, _) =
    _symbol "KEY_Z" public : ( unit -> int ) * ( int -> unit );
end
