structure Constants =
struct
  val windowWidth = 1000
  val windowHeight = 900
  val initialNumClickPoints = 15

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
    \}"

  val colouredVertexShaderString =
    "#version 300 es\n\
    \layout (location = 0) in vec2 apos;\n\
    \layout (location = 1) in vec3 col;\n\
    \out vec3 frag_col;\n\
    \void main()\n\
    \{\n\
    \   frag_col = col;\n\
    \   gl_Position = vec4(apos.x, apos.y, 0.0f, 1.0f);\n\
    \}"

  val colouredFragmentShaderString =
    "#version 300 es\n\
    \precision mediump float;\n\
    \in vec3 frag_col;\n\
    \out vec4 FragColor;\n\
    \void main()\n\
    \{\n\
    \   FragColor = vec4(frag_col.x, frag_col.y, frag_col.z, 1.0f);\n\
    \}"
end
