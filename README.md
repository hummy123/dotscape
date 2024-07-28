# box-x-box

## What is this?

This is a broken attempt at changing [box-x-box-c-callback](https://github.com/hummy123/box-x-box-c-callback) to accept a callback from an exported SML function instead.

It's broken because (at least on aarch64-linux) there is a segfault when trying to press a keyboard key (to trigger the key callback) when the window is focused.

## Building

Building the program and running it is exactly the same as it is for the C counterpart of this repository.

## How the callback is set in code

There are two files again, `ffi/glfw-key-input.c` and `ffi/glfw-key-input.sml` (which each have different contents from the C counterpart of this repository).

`ffi/glfw-key-input.c` has two functions:
- One callback function that does nothing but call a print function exported from SML
- One other function which, when called, will register the callback with GLFW

`ffi/glfw-key-input.sml` has two parts as well:
- Lines 5 - 6 define a function that is exported to C
- Line 9 imports a C function which calls the exported SML function (and this has the `reentrant` attribute).

The callback is registered with GLFW at runtime at line 32 of `imperative-shell/shell.sml`.

## Trying to narrow down the issue

### Don't register the callback

Deleting line 32 of `imperative-shell/shell.sml` will stop the program from giving a segfault but we obviously lose functionality that way.

This is mentioned because I think the issue is something to do with how the callback is set.

A (mostly) uninformed guess: The `reentrant` attribute for importing functions is meant to be used for importing C functions that call SML functions.

This is different from how GLFW works, which triggers the callback registered with it without MLton knowing.

(If this is the case, why does [simple-mlton-glfw-callback](https://github.com/hummy123/simple-mlton-glfw-callback) work?)

### Remove code dealing with vectors

Separately from removing the registration of the callback, we can make small edits to `functional-core/game-update.sml` and `imperative-shell/game-draw.sml` to avoid the segfault issue. (Both of these edits must be made together.)

#### Editing game-update.sml

In lines 269-270 of `functional-core/game-update.sml`, there's a call to a pure function which recreates a `block vector vector` type.

This function checks if a box/ball collides with any of the blocks. 

If a collision occurs, both the block and the colliding ball are recreated with different values.

If no collision occurs, the block and the ball keep the same value they had before (but the vector is still recreated).

We can delete these lines. Together with the one small edit to game-draw.sml described below, the segfault will stop occurring.

#### Editing game-draw.sml

In line 57 of `imperative-shell/game-draw.sml`, there is this line of code:

`val {lightBlocks, darkBlocks} = drawBlocksLine (#blocks game)`

To make the seg fault go away, we can delete this line and replace it with:

```
val lightBlocks = []
val darkBlocks = []
```

With this change and the one to `functional-core/game-update.sml` described above, we can rebuild the program with `./build-unix.sh` and run it with `./box-x-box`. The key callback will work fine now.

What the `drawBlocksLine` function does is, it traverses the `block vector vector` (which was causing issues in game-update.sml), and it creates a `Real32.real vector list` from them (one being `darkBlocks` and the other being `lightBlocks`). The results are later sent to OpenGL.

Note that the `drawBlocksLine` function is pure. It returns a `Real32.real vector list` and does no drawing/side-effecting/mutating on its own (making the name a misnomer).

---

Removing the code dealing with vectors is quite a strange solution. 

The two functions, `drawBlocksLine` in game-draw.sml and `updateBlocks` ins game-update.sml, are both pure and I can't think of why they would be connected with the key callback/a segfault.

The C counterpart of this repository has both of those functions in place (unmodified) which leads me to guEss the error isn't in these functions themselves.
