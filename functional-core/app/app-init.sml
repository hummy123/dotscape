signature APP_INIT =
sig
  val fromWindowWidthAndHeight: int * int * int -> AppType.app_type
end

structure AppInit :> APP_INIT =
struct
  open AppType

  fun helpFromWidthAndHeight
    ( windowWidth
    , windowHeight
    , wStart
    , wFinish
    , hStart
    , hFinish
    , numClickPoints
    ) : app_type =
    let
      val xClickPoints = ClickPoints.generate (wStart, wFinish, numClickPoints)
      val yClickPoints = ClickPoints.generate (hStart, hFinish, numClickPoints)
    in
      { mode = AppType.NORMAL_MODE
      , triangles = []
      , triangleStage = NO_TRIANGLE
      , windowWidth = windowWidth
      , windowHeight = windowHeight
      , numClickPoints = numClickPoints
      , xClickPoints = xClickPoints
      , yClickPoints = yClickPoints
      , undo = []
      , redo = []
      , mouseX = 0.0
      , mouseY = 0.0
      , showGraph = true
      , arrowX = 0
      , arrowY = 0
      , openFilePath = ""
      , fileBrowser = Vector.fromList []
      }
    end

  fun fromWindowWidthAndHeight (windowWidth, windowHeight, numClickPoints) =
    if windowWidth = windowHeight then
      helpFromWidthAndHeight
        ( windowWidth
        , windowHeight
        , 0
        , windowWidth
        , 0
        , windowHeight
        , numClickPoints
        )
    else if windowWidth > windowHeight then
      let
        val difference = windowWidth - windowHeight
        val wStart = difference div 2
        val wFinish = wStart + windowHeight
      in
        helpFromWidthAndHeight
          ( windowWidth
          , windowHeight
          , wStart
          , wFinish
          , 0
          , windowHeight
          , numClickPoints
          )
      end
    else
      let
        val difference = windowHeight - windowWidth
        val hStart = difference div 2
        val hFinish = hStart + windowWidth
      in
        helpFromWidthAndHeight
          ( windowWidth
          , windowHeight
          , 0
          , windowWidth
          , hStart
          , hFinish
          , numClickPoints
          )
      end
end
