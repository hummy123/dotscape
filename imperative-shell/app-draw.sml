structure AppDraw = 
struct
  val graphLines = 
    #[
      (* x = ~0.95 *)
      ~0.949, ~1.0,
      ~0.951, ~1.0,
      ~0.951, 1.0,

      ~0.951, 1.0,
      ~0.949, 1.0,
      ~0.949, ~1.0,

      (* x = ~0.9 *)
      ~0.898, ~1.0,
      ~0.902, ~1.0,
      ~0.902, 1.0,

      ~0.902, 1.0,
      ~0.898, 1.0,
      ~0.898, ~1.0,

      (* x = ~0.85 *)
      ~0.849, ~1.0,
      ~0.851, ~1.0,
      ~0.851, 1.0,

      ~0.851, 1.0,
      ~0.849, 1.0,
      ~0.849, ~1.0,

      (* x = ~0.8 *)
      ~0.798, ~1.0,
      ~0.802, ~1.0,
      ~0.802, 1.0,

      ~0.802, 1.0,
      ~0.798, 1.0,
      ~0.798, ~1.0,

      (* x = ~0.75 *)
      ~0.749, ~1.0,
      ~0.751, ~1.0,
      ~0.751, 1.0,

      ~0.751, 1.0,
      ~0.749, 1.0,
      ~0.749, ~1.0,

      (* x = ~0.7 *)
      ~0.698, ~1.0,
      ~0.702, ~1.0,
      ~0.702, 1.0,

      ~0.702, 1.0,
      ~0.698, 1.0,
      ~0.698, ~1.0,

      (* x = ~0.65 *)
      ~0.649, ~1.0,
      ~0.651, ~1.0,
      ~0.651, 1.0,

      ~0.651, 1.0,
      ~0.649, 1.0,
      ~0.649, ~1.0,

      (* x = ~0.6 *)
      ~0.598, ~1.0,
      ~0.602, ~1.0,
      ~0.602, 1.0,

      ~0.602, 1.0,
      ~0.598, 1.0,
      ~0.598, ~1.0,

      (* x = ~0.55 *)
      ~0.549, ~1.0,
      ~0.551, ~1.0,
      ~0.551, 1.0,

      ~0.551, 1.0,
      ~0.549, 1.0,
      ~0.549, ~1.0,

      (* x = ~0.5 *)
      ~0.498, ~1.0,
      ~0.502, ~1.0,
      ~0.502, 1.0,

      ~0.502, 1.0,
      ~0.498, 1.0,
      ~0.498, ~1.0,

      (* x = ~0.45 *)
      ~0.449, ~1.0,
      ~0.451, ~1.0,
      ~0.451, 1.0,

      ~0.451, 1.0,
      ~0.449, 1.0,
      ~0.449, ~1.0,

      (* x = ~0.4 *)
      ~0.398, ~1.0,
      ~0.402, ~1.0,
      ~0.402, 1.0,

      ~0.402, 1.0,
      ~0.398, 1.0,
      ~0.398, ~1.0,

      (* x = ~0.35 *)
      ~0.349, ~1.0,
      ~0.351, ~1.0,
      ~0.351, 1.0,

      ~0.351, 1.0,
      ~0.349, 1.0,
      ~0.349, ~1.0,

      (* x = ~0.3 *)
      ~0.298, ~1.0,
      ~0.302, ~1.0,
      ~0.302, 1.0,

      ~0.302, 1.0,
      ~0.298, 1.0,
      ~0.298, ~1.0,

      (* x = ~0.25 *)
      ~0.249, ~1.0,
      ~0.251, ~1.0,
      ~0.251, 1.0,

      ~0.251, 1.0,
      ~0.249, 1.0,
      ~0.249, ~1.0,

      (* x = ~0.2 *)
      ~0.198, ~1.0,
      ~0.202, ~1.0,
      ~0.202, 1.0,

      ~0.202, 1.0,
      ~0.198, 1.0,
      ~0.198, ~1.0,

      (* x = ~0.15 *)
      ~0.149, ~1.0,
      ~0.151, ~1.0,
      ~0.151, 1.0,

      ~0.151, 1.0,
      ~0.149, 1.0,
      ~0.149, ~1.0,

      (* x = ~0.1 *)
      ~0.098, ~1.0,
      ~0.102, ~1.0,
      ~0.102, 1.0,

      ~0.102, 1.0,
      ~0.098, 1.0,
      ~0.098, ~1.0,

      (* x = ~0.05 *)
      ~0.049, ~1.0,
      ~0.051, ~1.0,
      ~0.051, 1.0,

      ~0.051, 1.0,
      ~0.049, 1.0,
      ~0.049, ~1.0,

      (* x = 0.0 *)
      ~0.002, ~1.0,
      0.002, ~1.0,
      0.002, 1.0,

      0.002, 1.0,
      ~0.002, 1.0,
      ~0.002, ~1.0,

      (* x = 0.05 *)
      0.049, ~1.0,
      0.051, ~1.0,
      0.051, 1.0,

      0.051, 1.0,
      0.049, 1.0,
      0.049, ~1.0,

      (* x = 0.0 *)
      0.098, ~1.0,
      0.102, ~1.0,
      0.102, 1.0,

      0.102, 1.0,
      0.098, 1.0,
      0.098, ~1.0,

      (* x = 0.15 *)
      0.149, ~1.0,
      0.151, ~1.0,
      0.151, 1.0,

      0.151, 1.0,
      0.149, 1.0,
      0.149, ~1.0,

      (* x = 0.2 *)
      0.198, ~1.0,
      0.202, ~1.0,
      0.202, 1.0,

      0.202, 1.0,
      0.198, 1.0,
      0.198, ~1.0,

      (* x = 0.25 *)
      0.249, ~1.0,
      0.251, ~1.0,
      0.251, 1.0,

      0.251, 1.0,
      0.249, 1.0,
      0.249, ~1.0,

      (* x = 0.3 *)
      0.298, ~1.0,
      0.302, ~1.0,
      0.302, 1.0,

      0.302, 1.0,
      0.298, 1.0,
      0.298, ~1.0,

      (* x = 0.35 *)
      0.349, ~1.0,
      0.351, ~1.0,
      0.351, 1.0,

      0.351, 1.0,
      0.349, 1.0,
      0.349, ~1.0,

      (* x = 0.4 *)
      0.398, ~1.0,
      0.402, ~1.0,
      0.402, 1.0,

      0.402, 1.0,
      0.398, 1.0,
      0.398, ~1.0,

      (* x = 0.45 *)
      0.449, ~1.0,
      0.451, ~1.0,
      0.451, 1.0,

      0.451, 1.0,
      0.449, 1.0,
      0.449, ~1.0,

      (* x = 0.5 *)
      0.498, ~1.0,
      0.502, ~1.0,
      0.502, 1.0,

      0.502, 1.0,
      0.498, 1.0,
      0.498, ~1.0,

      (* x = 0.55 *)
      0.549, ~1.0,
      0.551, ~1.0,
      0.551, 1.0,

      0.551, 1.0,
      0.549, 1.0,
      0.549, ~1.0,

      (* x = 0.6 *)
      0.598, ~1.0,
      0.602, ~1.0,
      0.602, 1.0,

      0.602, 1.0,
      0.598, 1.0,
      0.598, ~1.0,

      (* x = 0.65 *)
      0.649, ~1.0,
      0.651, ~1.0,
      0.651, 1.0,

      0.651, 1.0,
      0.649, 1.0,
      0.649, ~1.0,

      (* x = 0.7 *)
      0.698, ~1.0,
      0.702, ~1.0,
      0.702, 1.0,

      0.702, 1.0,
      0.698, 1.0,
      0.698, ~1.0,

      (* x = 0.75 *)
      0.749, ~1.0,
      0.751, ~1.0,
      0.751, 1.0,

      0.751, 1.0,
      0.749, 1.0,
      0.749, ~1.0,

      (* x = 0.8 *)
      0.798, ~1.0,
      0.802, ~1.0,
      0.802, 1.0,

      0.802, 1.0,
      0.798, 1.0,
      0.798, ~1.0,

      (* x = 0.85 *)
      0.849, ~1.0,
      0.851, ~1.0,
      0.851, 1.0,

      0.851, 1.0,
      0.849, 1.0,
      0.849, ~1.0,

      (* x = 0.9 *)
      0.898, ~1.0,
      0.902, ~1.0,
      0.902, 1.0,

      0.902, 1.0,
      0.898, 1.0,
      0.898, ~1.0,

      (* x = 0.95 *)
      0.949, ~1.0,
      0.951, ~1.0,
      0.951, 1.0,

      0.951, 1.0,
      0.949, 1.0,
      0.949, ~1.0,

      (* y = ~0.95 *)
      ~1.0, ~0.949,
      ~1.0, ~0.951,
      1.0, ~0.951, 

      1.0, ~0.951,
      1.0, ~0.949,
      ~1.0, ~0.949,

      (* y = ~0.9 *)
      ~1.0, ~0.898, 
      ~1.0, ~0.902, 
      1.0, ~0.902, 

      1.0, ~0.902, 
      1.0, ~0.898, 
      ~1.0, ~0.898, 

      (* y = ~0.85 *)
      ~1.0, ~0.849, 
      ~1.0, ~0.851, 
      1.0, ~0.851, 

      1.0, ~0.851, 
      1.0, ~0.849, 
      ~1.0, ~0.849, 

      (* y = ~0.8 *)
      ~1.0, ~0.798, 
      ~1.0, ~0.802, 
      1.0, ~0.802, 

      1.0, ~0.802, 
      1.0, ~0.798, 
      ~1.0, ~0.798, 

      (* y = ~0.75 *)
      ~1.0, ~0.749, 
      ~1.0, ~0.751, 
      1.0, ~0.751, 

      1.0, ~0.751, 
      1.0, ~0.749, 
      ~1.0, ~0.749, 

      (* y = ~0.7 *)
      ~1.0, ~0.698, 
      ~1.0, ~0.702, 
      1.0, ~0.702, 

      1.0, ~0.702, 
      1.0, ~0.698, 
      ~1.0, ~0.698, 

      (* y = ~0.65 *)
      ~1.0, ~0.649, 
      ~1.0, ~0.651, 
      1.0, ~0.651, 

      1.0, ~0.651, 
      1.0, ~0.649, 
      ~1.0, ~0.649, 

      (* y = ~0.6 *)
      ~1.0, ~0.598, 
      ~1.0, ~0.602, 
      1.0, ~0.602, 

      1.0, ~0.602, 
      1.0, ~0.598, 
      ~1.0, ~0.598, 

      (* y = ~0.55 *)
      ~1.0, ~0.549, 
      ~1.0, ~0.551, 
      1.0, ~0.551, 

      1.0, ~0.551, 
      1.0, ~0.549, 
      ~1.0, ~0.549, 

      (* y = ~0.5 *)
      ~1.0, ~0.498, 
      ~1.0, ~0.502, 
      1.0, ~0.502, 

      1.0, ~0.502, 
      1.0, ~0.498, 
      ~1.0, ~0.498, 

      (* y = ~0.45 *)
      ~1.0, ~0.449, 
      ~1.0, ~0.451, 
      1.0, ~0.451, 

      1.0, ~0.451, 
      1.0, ~0.449, 
      ~1.0, ~0.449, 

      (* y = ~0.4 *)
      ~1.0, ~0.398, 
      ~1.0, ~0.402, 
      1.0, ~0.402, 

      1.0, ~0.402, 
      1.0, ~0.398, 
      ~1.0, ~0.398, 

      (* y = ~0.35 *)
      ~1.0, ~0.349, 
      ~1.0, ~0.351, 
      1.0, ~0.351, 

      1.0, ~0.351, 
      1.0, ~0.349, 
      ~1.0, ~0.349, 

      (* y = ~0.3 *)
      ~1.0, ~0.298, 
      ~1.0, ~0.302, 
      1.0, ~0.302, 

      1.0, ~0.302, 
      1.0, ~0.298, 
      ~1.0, ~0.298, 

      (* y = ~0.25 *)
      ~1.0, ~0.249, 
      ~1.0, ~0.251, 
      1.0, ~0.251, 

      1.0, ~0.251, 
      1.0, ~0.249, 
      ~1.0, ~0.249, 

      (* y = ~0.2 *)
      ~1.0, ~0.198, 
      ~1.0, ~0.202, 
      1.0, ~0.202, 

      1.0, ~0.202, 
      1.0, ~0.198, 
      ~1.0, ~0.198, 

      (* y = ~0.15 *)
      ~1.0, ~0.149, 
      ~1.0, ~0.151, 
      1.0, ~0.151, 

      1.0, ~0.151, 
      1.0, ~0.149, 
      ~1.0, ~0.149, 

      (* y = ~0.1 *)
      ~1.0, ~0.098, 
      ~1.0, ~0.102, 
      1.0, ~0.102, 

      1.0, ~0.102, 
      1.0, ~0.098, 
      ~1.0, ~0.098, 

      (* y = ~0.05 *)
      ~1.0, ~0.049, 
      ~1.0, ~0.051, 
      1.0, ~0.051, 

      1.0, ~0.051, 
      1.0, ~0.049, 
      ~1.0, ~0.049, 

      (* y = 0.0 *)
      ~1.0, ~0.002, 
      ~1.0, 0.002, 
      1.0, 0.002, 

      1.0, 0.002, 
      1.0, ~0.002, 
      ~1.0, ~0.002, 

      (* y = 0.05 *)
      ~1.0, 0.049, 
      ~1.0, 0.051, 
      1.0, 0.051, 

      1.0, 0.051, 
      1.0, 0.049, 
      ~1.0, 0.049, 

      (* y = 0.0 *)
      ~1.0, 0.098, 
      ~1.0, 0.102, 
      1.0, 0.102, 

      1.0, 0.102, 
      1.0, 0.098, 
      ~1.0, 0.098, 

      (* y = 0.15 *)
      ~1.0, 0.149, 
      ~1.0, 0.151, 
      1.0, 0.151, 

      1.0, 0.151, 
      1.0, 0.149, 
      ~1.0, 0.149, 

      (* y = 0.2 *)
      ~1.0, 0.198, 
      ~1.0, 0.202, 
      1.0, 0.202, 

      1.0, 0.202, 
      1.0, 0.198, 
      ~1.0, 0.198, 

      (* y = 0.25 *)
      ~1.0, 0.249, 
      ~1.0, 0.251, 
      1.0, 0.251, 

      1.0, 0.251, 
      1.0, 0.249, 
      ~1.0, 0.249, 

      (* y = 0.3 *)
      ~1.0, 0.298, 
      ~1.0, 0.302, 
      1.0, 0.302, 

      1.0, 0.302, 
      1.0, 0.298, 
      ~1.0, 0.298, 

      (* y = 0.35 *)
      ~1.0, 0.349, 
      ~1.0, 0.351, 
      1.0, 0.351, 

      1.0, 0.351, 
      1.0, 0.349, 
      ~1.0, 0.349, 

      (* y = 0.4 *)
      ~1.0, 0.398, 
      ~1.0, 0.402, 
      1.0, 0.402, 

      1.0, 0.402, 
      1.0, 0.398, 
      ~1.0, 0.398, 

      (* y = 0.45 *)
      ~1.0, 0.449, 
      ~1.0, 0.451, 
      1.0, 0.451, 

      1.0, 0.451, 
      1.0, 0.449, 
      ~1.0, 0.449, 

      (* y = 0.5 *)
      ~1.0, 0.498, 
      ~1.0, 0.502, 
      1.0, 0.502, 

      1.0, 0.502, 
      1.0, 0.498, 
      ~1.0, 0.498, 

      (* y = 0.55 *)
      ~1.0, 0.549, 
      ~1.0, 0.551, 
      1.0, 0.551, 

      1.0, 0.551, 
      1.0, 0.549, 
      ~1.0, 0.549, 

      (* y = 0.6 *)
      ~1.0, 0.598, 
      ~1.0, 0.602, 
      1.0, 0.602, 

      1.0, 0.602, 
      1.0, 0.598, 
      ~1.0, 0.598, 

      (* y = 0.65 *)
      ~1.0, 0.649, 
      ~1.0, 0.651, 
      1.0, 0.651, 

      1.0, 0.651, 
      1.0, 0.649, 
      ~1.0, 0.649, 

      (* y = 0.7 *)
      ~1.0, 0.698, 
      ~1.0, 0.702, 
      1.0, 0.702, 

      1.0, 0.702, 
      1.0, 0.698, 
      ~1.0, 0.698, 

      (* y = 0.75 *)
      ~1.0, 0.749, 
      ~1.0, 0.751, 
      1.0, 0.751, 

      1.0, 0.751, 
      1.0, 0.749, 
      ~1.0, 0.749, 

      (* y = 0.8 *)
      ~1.0, 0.798, 
      ~1.0, 0.802, 
      1.0, 0.802, 

      1.0, 0.802, 
      1.0, 0.798, 
      ~1.0, 0.798, 

      (* y = 0.85 *)
      ~1.0, 0.849, 
      ~1.0, 0.851, 
      1.0, 0.851, 

      1.0, 0.851, 
      1.0, 0.849, 
      ~1.0, 0.849, 

      (* y = 0.9 *)
      ~1.0, 0.898, 
      ~1.0, 0.902, 
      1.0, 0.902, 

      1.0, 0.902, 
      1.0, 0.898, 
      ~1.0, 0.898, 

      (* y = 0.95 *)
      ~1.0, 0.949, 
      ~1.0, 0.951, 
      1.0, 0.951, 

      1.0, 0.951, 
      1.0, 0.949, 
      ~1.0, 0.949
     ]
end
