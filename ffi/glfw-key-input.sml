structure Key =
struct
  type window = MLton.Pointer.t

  (* Export function to C. *)
  val export =
    _export "printFromMLton" public : (int * int * int * int -> unit) -> unit;

  (* Import function to set callback for GLFW. *)
  val setCallback = _import "setKeyCallback" public reentrant : window -> unit;
end
