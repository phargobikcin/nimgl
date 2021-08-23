# Copyright 2018, NimGL contributors.

import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_sdl]
import nimgl/[opengl]
import sdl2nim/sdl as sdl

template fatalSDLError(s: string) =
  let error = "ERROR: sdl.createWindow(): " & $sdl.getError()
  raise newException(Exception, error)

proc main() =
  # initialise SDL
  if sdl.init(sdl.INIT_VIDEO) != 0:
    fatalSDLError("Could not initialize SDL: ")

  discard glSetAttribute(GLattr.GL_CONTEXT_PROFILE_MASK, GL_CONTEXT_PROFILE_CORE)

  discard glSetAttribute(GLattr.GL_CONTEXT_FLAGS,
                         GL_CONTEXT_DEBUG_FLAG or GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)

  discard glSetAttribute(GLattr.GL_CONTEXT_MAJOR_VERSION, 3)
  discard glSetAttribute(GLattr.GL_CONTEXT_MINOR_VERSION, 3)
  discard glSetAttribute(GLattr.GL_DOUBLEBUFFER, 1)

  # create window
  var window = sdl.createWindow(
    "hello world",
    sdl.WINDOWPOS_CENTERED,
    sdl.WINDOWPOS_CENTERED,
    800,
    600,
    sdl.WINDOW_OPENGL or sdl.WINDOW_SHOWN or sdl.WINDOW_RESIZABLE)

  if window == nil:
    fatalSDLError("error in sdl.createWindow(): ")

  var glContext = sdl.glCreateContext(window)
  if glContext == nil:
    fatalSDLError("Can't create OpenGL context: ")
  discard sdl.glMakeCurrent(window, glContext)

  doAssert glInit()

  let context = igCreateContext()
  doAssert igSDL2InitForOpenGL(window, glContext)
  doAssert igOpenGL3Init()

  igStyleColorsCherry()

  var showDemo = true
  var somefloat: float32 = 0.0f
  var counter: int32 = 0

  var quitRequested = false
  while not quitRequested:
    var e: sdl.Event
    while sdl.pollEvent(addr e) != 0:
      if e.kind == sdl.QUIT:
        quitRequested = true

      igSDL2_ProcessEvent(event)


    igOpenGL3NewFrame()
    igSDL2NewFrame(window)
    igNewFrame()

    if showDemo:
      igShowDemoWindow(showDemo.addr)

    # Simple window
    igBegin("Hello, world!")

    igText("This is some useful text.")
    igCheckbox("Demo Window", showDemo.addr)

    igSliderFloat("float", somefloat.addr, 0.0f, 1.0f)

    if igButton("Button", ImVec2(x: 0, y: 0)):
      counter.inc
    igSameLine()
    igText("counter = %d", counter)
    igSameLine()
    if igButton("Reset", ImVec2(x: 0, y: 0)):
      counter =0


    igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().framerate, igGetIO().framerate)
    igEnd()
    # End simple window

    igRender()

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    sdl.glSwapWindow(window)

  igOpenGL3Shutdown()
  igSDL2Shutdown()
  context.igDestroyContext()

  sdl.glDeleteContext(glContext)
  sdl.destroyWindow(window)
  sdl.quit()


main()
