signature GRAPH_LINES =
sig
  val generate: AppType.app_type -> Real32.real vector
end

structure GraphLines :> GRAPH_LINES =
struct
  fun generate (app: AppType.app_type) =
    let
      val {windowWidth, windowHeight, xClickPoints, yClickPoints, ...} = app
    in
      Vector.concat (List.tabulate (Vector.length xClickPoints, fn xIdx =>
        let
          val xpos = Vector.sub (xClickPoints, xIdx)
        in
          Vector.concat (List.tabulate (Vector.length yClickPoints, fn yIdx =>
            ClickPoints.getDrawDot
              (xpos, Vector.sub (yClickPoints, yIdx), windowWidth, windowHeight)))
        end))
    end
end
