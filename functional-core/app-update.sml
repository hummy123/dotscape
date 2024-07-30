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
    fun getVerticalClickPos (idx, horizontalPos, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        #[]
      else
        let
          val curVerticalPos = Vector.sub (clickPoints, idx)
        in
          if mouseY < curVerticalPos - 10 orelse mouseY > curVerticalPos + 10 then
            getVerticalClickPos
              (idx + 1, horizontalPos, mouseX, mouseY, r, g, b)
          else
            let
              val left = Real32.fromInt (horizontalPos - 10) / 500.0
              val right = Real32.fromInt (horizontalPos + 10) / 500.0
              val bottom = Real32.fromInt (curVerticalPos - 10) / 500.0
              val top = Real32.fromInt (curVerticalPos + 10) / 500.0
            in
             #[ left, bottom, r, g, b,
                right, bottom, r, g, b,
                left, top, r, g, b,

                left, top, r, g, b,
                right, bottom, r, g, b,
                right, top, r, g, b
              ]
            end
        end

    fun getHorizontalClickPos (idx, mouseX, mouseY, r, g, b) =
      if idx = Vector.length clickPoints then
        #[]
      else
        let
          val curPos = Vector.sub (clickPoints, idx)
        in
          if mouseX < curPos - 10 orelse mouseX > curPos + 10 then
            getHorizontalClickPos (idx + 1, mouseX, mouseY, r, g, b)
          else
            getVerticalClickPos (0, curPos, mouseX, mouseY, r, g, b)
        end
  in
    (*
     * This function returns a vector containing the position data of the
     * clicked square.
     * If a square wasn't found at the clicked position, 
     * an empty vector is returned.
     *)
    fun getClickPos (mouseX, mouseY, r, g, b) =
      getHorizontalClickPos (0, mouseX, mouseY, r, g, b)
  end
end
