structure Constants =
struct
  val graphVertexShaderString =
    "#version 300 es\n\
    \layout (location = 0) in vec2 apos;\n\
    \void main()\n\
    \{\n\
    \   gl_Position = vec4(apos.x, apos.y, 0.0f, 1.0f);\n\
    \}"

  val graphFragmentShaderString =
    "#version 300 es\n\
    \precision mediump float;\n\
    \out vec4 FragColor;\n\
    \void main()\n\
    \{\n\
    \   FragColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);\n\
    \}";
end
