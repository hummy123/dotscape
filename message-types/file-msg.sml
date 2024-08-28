signature FILE_MESSAGE =
sig
  datatype t =
    SAVE_TRIANGLES of AppType.triangle list
  | EXPORT_FILE of AppType.triangle list
  | IMPORT_FILE
end

structure FileMessage :> FILE_MESSAGE =
struct
  datatype t =
    SAVE_TRIANGLES of AppType.triangle list
  | EXPORT_FILE of AppType.triangle list
  | IMPORT_FILE
end
