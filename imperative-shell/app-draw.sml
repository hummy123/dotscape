structure AppDraw =
struct
  type draw_object =
    { vertexBuffer: Word32.word
    , vertexShader: Word32.word
    , fragmentBuffer: Word32.word
    , fragmentShader: Word32.word
    , program: Word32.word
    }

  fun initDrawObject (vertexShaderString, fragmentShaderString) : draw_object =
    let
      val vertexBuffer = Gles3.createBuffer ()
      val vertexShader = Gles3.createShader (Gles3.VERTEX_SHADER ())
      val _ = Gles3.shaderSource (vertexShader, vertexShaderString)
      val _ = Gles3.compileShader vertexShader

      val fragmentBuffer = Gles3.createBuffer ()
      val fragmentShader = Gles3.createShader (Gles3.FRAGMENT_SHADER ())
      val _ = Gles3.shaderSource (fragmentShader, fragmentShaderString)
      val _ = Gles3.compileShader fragmentShader

      val program = Gles3.createProgram ()
      val _ = Gles3.attachShader (program, vertexShader)
      val _ = Gles3.attachShader (program, fragmentShader)
      val _ = Gles3.linkProgram program
    in
      { vertexBuffer = vertexBuffer
      , vertexShader = vertexShader
      , fragmentBuffer = fragmentBuffer
      , fragmentShader = fragmentShader
      , program = program
      }
    end

  fun initGraphLines () =
    let
      val graphDrawObject = initDrawObject
        (Constants.graphVertexShaderString, Constants.graphFragmentShaderString)
      val {vertexBuffer, program, ...} = graphDrawObject

      val _ = Gles3.bindBuffer vertexBuffer
      val _ =
        Gles3.bufferData
          ( Constants.graphLines
          , Vector.length Constants.graphLines
          , Gles3.STATIC_DRAW ()
          )
      val _ = Gles3.vertexAttribPointer (0, 2, 2, 0)
      val _ = Gles3.enableVertexAttribArray 0
    in
      graphDrawObject
    end

  fun drawGraphLines (graphDrawObject: draw_object) =
    let
      val {vertexBuffer, program, ...} = graphDrawObject
      val _ = Gles3.bindBuffer vertexBuffer
      val _ = Gles3.vertexAttribPointer (0, 2, 2, 0)
      val _ = Gles3.enableVertexAttribArray 0
      val _ = Gles3.useProgram program
      val _ = Gles3.drawArrays
        (Gles3.TRIANGLES (), 0, Vector.length Constants.graphLines div 2)
    in
      ()
    end

  val buttonVec =
   #[ 0.5, 0.5, 1.0, 0.0, 0.0
    , 0.5, ~0.5, 1.0, 0.0, 0.0
    , ~0.5, 0.5, 1.0, 0.0, 0.0

    , 0.5, ~0.5, 0.0, 0.0, 1.0
    , ~0.5, ~0.5, 0.0, 0.0, 1.0
    , ~0.5, 0.5, 0.0, 0.0, 1.0
    ]

  fun initButton () =
    let
      val buttonDrawObject = initDrawObject
        ( Constants.colouredVertexShaderString
        , Constants.colouredFragmentShaderString
        )
      val {vertexBuffer, program, ...} = buttonDrawObject

      val _ = Gles3.bindBuffer vertexBuffer
      val _ =
        Gles3.bufferData
          (buttonVec, Vector.length buttonVec, Gles3.STATIC_DRAW ())
      val _ = Gles3.vertexAttribPointer (0, 2, 5, 0)
      val _ = Gles3.enableVertexAttribArray 0

      val _ = Gles3.vertexAttribPointer (1, 3, 5, 8)
      val _ = Gles3.enableVertexAttribArray 1
    in
      buttonDrawObject
    end

  fun uploadButtonVector (buttonDrawObject: draw_object, vec) =
    let
      val {vertexBuffer, ...} = buttonDrawObject
      val _ = Gles3.bindBuffer vertexBuffer
      val _ = Gles3.bufferData (vec, Vector.length vec, Gles3.STATIC_DRAW ())
    in
      ()
    end

  fun drawButton (buttonDrawObject: draw_object, vec) =
    let
      val {vertexBuffer, program, ...} = buttonDrawObject
      val _ = Gles3.bindBuffer vertexBuffer
      val _ = Gles3.vertexAttribPointer (0, 2, 5, 0)
      val _ = Gles3.enableVertexAttribArray 0
      val _ = Gles3.vertexAttribPointer (1, 3, 5, 8)
      val _ = Gles3.enableVertexAttribArray 1
      val _ = Gles3.useProgram program
      val _ = Gles3.drawArrays
        (Gles3.TRIANGLES (), 0, Vector.length buttonVec div 5)
    in
      ()
    end

end
