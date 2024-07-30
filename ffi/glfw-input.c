#include "export.h"
#include <GLFW/glfw3.h>

int MOUSE_PRESSED = GLFW_PRESS;
int MOUSE_RELEASED = GLFW_RELEASE;
int LEFT_MOUSE_BUTTON = GLFW_MOUSE_BUTTON_1;

// Calls function exported from SML 
void mouseMoveCallback(GLFWwindow *window, double xpos, double ypos) {
  mltonMouseMoveCallback((int)xpos, (int)ypos);
}

void mouseClickCallback(GLFWwindow *window, int button, int action, int mods) {
  mltonMouseClickCallback(button, action);
}

// Call this from MLton to register key callback with GLFW.
void setMouseMoveCallback(GLFWwindow *window) {
  glfwSetCursorPosCallback(window, mouseMoveCallback);
}

void setMouseClickCallback(GLFWwindow *window) {
  glfwSetMouseButtonCallback(window, mouseClickCallback);
}

