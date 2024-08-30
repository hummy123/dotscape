structure LowerCaseA =
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
       #[      (((startX * (1.0 - 0.47499999404)) + (endX * 0.47499999404)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.700000047684)) + (endY * 0.700000047684)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.299999982119)) + (endX * 0.299999982119)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.675000011921)) + (endY * 0.675000011921)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.449999988079)) + (endX * 0.449999988079)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.550000011921)) + (endY * 0.550000011921)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.625)) + (endX * 0.625)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.275000035763)) + (endY * 0.275000035763)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.799999952316)) + (endX * 0.799999952316)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.400000035763)) + (endY * 0.400000035763)) / windowHeight) - 1.0,
      (((startX * (1.0 - 0.524999976158)) + (endX * 0.524999976158)) / windowWidth) - 1.0,
      (((startY * (1.0 - 0.524999976158)) + (endY * 0.524999976158)) / windowHeight) - 1.0
    ]
  end
end