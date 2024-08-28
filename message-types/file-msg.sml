signature FILE_MESSAGE =
sig
  datatype t =
    SAVE_TRIANGLES of AppType.triangle list
  | LOAD_TRIANGLES
  | EXPORT_TRIANGLES of AppType.triangle list
end

structure FileMessage :> FILE_MESSAGE =
struct
  datatype t =
    SAVE_TRIANGLES of AppType.triangle list
  | LOAD_TRIANGLES
  | EXPORT_TRIANGLES of AppType.triangle list
end
