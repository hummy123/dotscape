#include "export.h"
#include <GLFW/glfw3.h>

int MOUSE_PRESSED = GLFW_PRESS;
int MOUSE_RELEASED = GLFW_RELEASE;
int LEFT_MOUSE_BUTTON = GLFW_MOUSE_BUTTON_1;

// Calls function exported from SML 
void mouseMoveCallback(GLFWwindow *window, double xpos, double ypos) {
  mltonMouseMoveCallback((float)xpos, (float)ypos);
}

// Call this from MLton to register callback with GLFW.
void setMouseMoveCallback(GLFWwindow *window) {
  glfwSetCursorPosCallback(window, mouseMoveCallback);
}

void mouseClickCallback(GLFWwindow *window, int button, int action, int mods) {
  mltonMouseClickCallback(button, action);
}
void setMouseClickCallback(GLFWwindow *window) {
  glfwSetMouseButtonCallback(window, mouseClickCallback);
}

void framebufferSizeCallback(GLFWwindow *window, int width, int height) {
  mltonFramebufferSizeCallback(width, height);
}
void setFramebufferSizeCallback(GLFWwindow *window, int width, int height) {
  glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);
}
