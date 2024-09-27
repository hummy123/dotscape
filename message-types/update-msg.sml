signature UPDATE_MESSAGE =
sig
  datatype t = DRAW of DrawMessage.t | FILE of FileMessage.t
end

structure UpdateMessage :> UPDATE_MESSAGE =
struct datatype t = DRAW of DrawMessage.t | FILE of FileMessage.t end
