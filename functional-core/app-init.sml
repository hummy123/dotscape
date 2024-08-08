signature APP_INIT =
sig
  val fromWindowWidthAndHeight: int * int -> AppType.app_type
end

structure AppInit :> APP_INIT =
struct
  open AppType

  fun helpFromWidthAndHeight
    (windowWidth, windowHeight, wStart, wFinish, hStart, hFinish) =
    let
      val xClickPoints = ClickPoints.generate (wStart, wFinish)
      val yClickPoints = ClickPoints.generate (hStart, hFinish)
      val graphLines =
        GraphLines.generate
          (windowWidth, windowHeight, xClickPoints, yClickPoints)
    in
      { triangles = []
      , triangleStage = NO_TRIANGLE
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , graphLines = graphLines
      }
    end

  fun fromWindowWidthAndHeight (windowWidth, windowHeight) =
    if windowWidth = windowHeight then
      helpFromWidthAndHeight
        (windowWidth, windowHeight, 0, windowWidth, 0, windowHeight)
    else if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val wStart = difference div 2
        val wFinish = wStart + windowHeight
      in
        helpFromWidthAndHeight
          (windowWidth, windowHeight, wStart, wFinish, 0, windowHeight)
      end
    else
      let
        val difference = windowHeight - windowWidth
        val hStart = difference div 2
        val hFinish = hStart + windowWidth
      in
        helpFromWidthAndHeight
          (windowWidth, windowHeight, 0, windowWidth, hStart, hFinish)
      end
end
