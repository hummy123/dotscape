structure LowerCaseA =
struct
  fun lerp (startX, startY, drawWidth, drawHeight, windowWidth, windowHeight) =
    let
       val endX = startX + drawWidth
       val endY = startY + drawHeight
    in
       [      ((startX * (1.0 - 0.47499999404)) + (endX * 0.47499999404)) / windowWidth,
      ((startY * (1.0 - 0.700000047684)) + (endY * 0.700000047684)) / windowHeight,
      ((startX * (1.0 - 0.299999982119)) + (endX * 0.299999982119)) / windowWidth,
      ((startY * (1.0 - 0.675000011921)) + (endY * 0.675000011921)) / windowHeight,
      ((startX * (1.0 - 0.449999988079)) + (endX * 0.449999988079)) / windowWidth,
      ((startY * (1.0 - 0.550000011921)) + (endY * 0.550000011921)) / windowHeight,
      ((startX * (1.0 - 0.625)) + (endX * 0.625)) / windowWidth,
      ((startY * (1.0 - 0.275000035763)) + (endY * 0.275000035763)) / windowHeight,
      ((startX * (1.0 - 0.799999952316)) + (endX * 0.799999952316)) / windowWidth,
      ((startY * (1.0 - 0.400000035763)) + (endY * 0.400000035763)) / windowHeight,
      ((startX * (1.0 - 0.524999976158)) + (endX * 0.524999976158)) / windowWidth,
      ((startY * (1.0 - 0.524999976158)) + (endY * 0.524999976158)) / windowHeight
    ]
  end
end
