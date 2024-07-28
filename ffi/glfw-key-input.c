#include "export.h"
#include <GLFW/glfw3.h>
#include <stdbool.h>

// Calls function exported from SML 
void keyCallback(GLFWwindow *window, int key, int scancode, int action, int mods) {
  printFromMLton(key, scancode, action, mods);
}

// Call this from MLton to register key callback with GLFW.
void setKeyCallback(GLFWwindow *window) {
  glfwSetKeyCallback(window, keyCallback);
}

