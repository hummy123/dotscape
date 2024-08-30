structure UpperCaseA =
struct
  fun lerp (startX, startY, drawWidth, drawHeight, windowWidth, windowHeight) : Real32.real vector =
    let
       val startX = Real32.fromInt startX
       val startY = Real32.fromInt startY
       val endY = windowHeight - startY
       val startY = windowHeight - (startY + drawHeight)
       val endX = startX + drawWidth
       val windowHeight = windowHeight / 2.0
       val windowWidth = windowWidth / 2.0
    in
       #[      (((startX * (1.0 - 0.724999964237)) + (endX * 0.724999964237)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.325000017881)) + (endY * 0.325000017881)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.324999988079)) + (endX * 0.324999988079)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.474999964237)) + (endY * 0.474999964237)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.674999952316)) + (endX * 0.674999952316)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.474999964237)) + (endY * 0.474999964237)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.324999988079)) + (endX * 0.324999988079)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.474999964237)) + (endY * 0.474999964237)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.274999976158)) + (endX * 0.274999976158)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.325000017881)) + (endY * 0.325000017881)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.724999964237)) + (endX * 0.724999964237)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.325000017881)) + (endY * 0.325000017881)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.449999988079)) + (endX * 0.449999988079)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.600000023842)) + (endX * 0.600000023842)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 1.0)) + (endX * 1.0)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 1.0)) + (endX * 1.0)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.850000023842)) + (endX * 0.850000023842)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.449999988079)) + (endX * 0.449999988079)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.550000011921)) + (endX * 0.550000011921)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.40000000596)) + (endX * 0.40000000596)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.0)) + (endX * 0.0)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.0)) + (endX * 0.0)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.15000000596)) + (endX * 0.15000000596)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.0)) + (endY * 0.0)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.550000011921)) + (endX * 0.550000011921)) / windowWidth) - 1.0,
      (((startY * (1.0 - 1.0)) + (endY * 1.0)) / windowHeight) - 1.0
    ]
  end
end
