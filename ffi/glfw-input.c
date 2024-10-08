#include "export.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

int PRESS = GLFW_PRESS;
int RELEASE = GLFW_RELEASE;
int LEFT_MOUSE_BUTTON = GLFW_MOUSE_BUTTON_1;

int KEY_G = GLFW_KEY_G;
int KEY_Y = GLFW_KEY_Y;
int KEY_Z = GLFW_KEY_Z;

int KEY_S = GLFW_KEY_S;
int KEY_E = GLFW_KEY_E;
int KEY_I = GLFW_KEY_I;
int KEY_L = GLFW_KEY_L;
int KEY_O = GLFW_KEY_O;

int KEY_ENTER = GLFW_KEY_ENTER;
int KEY_SPACE = GLFW_KEY_SPACE;
int KEY_UP = GLFW_KEY_UP;
int KEY_LEFT = GLFW_KEY_LEFT;
int KEY_RIGHT = GLFW_KEY_RIGHT;
int KEY_DOWN = GLFW_KEY_DOWN;

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

void keyCallback(GLFWwindow *window, int key, int scancode, int action, int mods) {
  mltonKeyCallback(key, scancode, action, mods);
}
void setKeyCallback(GLFWwindow *window) {
  glfwSetKeyCallback(window, keyCallback);
}
