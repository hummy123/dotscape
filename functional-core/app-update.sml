structure AppUpdate =
struct
  val clickPoints =
   #[ 25
    , 50
    , 75
    , 100
    , 125
    , 150
    , 175
    , 200
    , 225
    , 250
    , 275
    , 300
    , 325
    , 350
    , 375
    , 400
    , 425
    , 450
    , 475
    ]

  local
    fun getVerticalClickPos (idx, horizontalPos, mouseX, mouseY) =
      if idx = Vector.length clickPoints then
        #[]
      else
        let
          val curVerticalPos = Vector.sub (clickPoints, idx)
        in
          if mouseY < curVerticalPos - 10 orelse mouseY > curVerticalPos + 10 then
            getVerticalClickPos (idx + 1, horizontalPos, mouseX, mouseY)
          else
            let
              val left = Real32.fromInt ((horizontalPos - 10) div 500)
              val right = Real32.fromInt ((horizontalPos + 10) div 500)
              val bottom = Real32.fromInt ((curVerticalPos - 10) div 500)
              val top = Real32.fromInt ((curVerticalPos + 10) div 500)
            in
              val highlightSquare = #[
                left, bottom, (* lower left *)
                right, bottom, (* lower right *)
                left, top, (* upper left *)

                left, top, (* upper left *)
                right, bottom, (* lower right *)
                right, top (* upper right *)
              ]
            end
        end

    fun getHorizontalClickPos (idx, mouseX, mouseY) =
      if idx = Vector.length clickPoints then
        #[]
      else
        let
          val curPos = Vector.sub (clickPoints, idx)
        in
          if mouseX < curPos - 10 orelse mouseX > curPos + 10 then
            getHorizontalClickPos (idx + 1, mouseX, mouseY)
          else
            getVerticalClickPos (0, curPos, mouseX, mouseY)
        end
  in
    (*
     * This function returns a vector containing the position data of the
     * clicked square.
     * If a square wasn't found at the clicked position, 
     * an empty vector is returned.
     *)
    fun getClickPos (mouseX, mouseY) = getHorizontalClickPos (0, mouseX, mouseY)
  end
end
