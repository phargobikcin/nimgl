# Copyright 2021, NimGL contributors.

## ImGUI SDL2 Implementation
## ====
## Implementation based on the imgui examples implementations.
## Feel free to use and modify this implementation.
## This needs to be used along with a Renderer.
##
## Based on : https://github.com/ocornut/imgui/blob/master/backends/imgui_impl_sdl.cpp (2020-05-25)
## Based on : https://github.com/ryback08/imgui/blob/master/src/imgui/impl_sdl.nim
##


import times
import ../imgui
import sdl2nim/sdl

# 60 // Data

var
  gWindow: sdl.Window
  gTime: float64 = 0.0f
  gMouseJustPressed: array[3, bool]
  gMouseCursors: array[ImGuiMouseCursor.high.int32 + 1, sdl.Cursor]
  gClipboardTextData: pointer = nil                                     # ???
  gMouseCanUseGlobalState: bool = true


proc getTicks(): float64 =
  let curTime = times.getTime()
  result = curTime.toUnix().float64 + curTime.nanosecond() / 1000000000


### igSDL2GetClipboardText : OK - Not tested
proc igSDL2GetClipboardText(userData: pointer): cstring {.cdecl.} =
  if gClipboardTextData != nil:
    sdl.free(gClipboardTextData)
  gClipboardTextData = sdl.getClipboardText()
  return cast[cstring](gClipboardTextData)


### igSDL2SetClipboardText OK - Not tested
proc igSDL2SetClipboardText(userData: pointer, text: cstring): void {.cdecl.} =
  discard sdl.setClipboardText(text)


## You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
## - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
## - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
## Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
## If you have multiple SDL events and some of them are not meant to be used by dear imgui, you may need to filter events based on their windowID field.

proc igSDL2_ProcessEvent*(event: sdl.Event) =
  let io = igGetIO()

  if event.kind == sdl.KEYDOWN or event.kind == KEYUP:
    # Show what key was pressed
    let key = event.key.keysym.scancode
    echo "Pressed: ", key

    #doAssert key >= 0 && key < IM_ARRAYSIZE(io.KeysDown)
    io.keysDown[key.int32] = event.kind == sdl.KEYDOWN

    let modState = sdl.getModState().ord()
    io.keyShift = (modState and KMOD_SHIFT.int) != 0
    io.keyCtrl = (modState and KMOD_CTRL.int) != 0
    io.keyAlt = (modState and KMOD_ALT.int) != 0

    # XXX does this work?
    #when defined windows:
    when defined(WIN32):
      io.keySuper = false
    else:
      io.keySuper = (modState and KMOD_GUI.int) != 0

  elif event.kind == sdl.MOUSEBUTTONDOWN:
    if event.button.button == sdl.BUTTON_LEFT:
      gMouseJustPressed[0] = true
    if event.button.button == sdl.BUTTON_RIGHT:
      gMouseJustPressed[1] = true
    if event.button.button == sdl.BUTTON_MIDDLE:
      gMouseJustPressed[2] = true


### igSDL2Init : Not finish
proc igSDL2Init(window: sdl.Window): bool =
  gWindow = window

  # Setup backend capabilities flags
  let io = igGetIO()
  # We can honor GetMouseCursor() values (optional)
  io.backendFlags = (io.backendFlags.int32 or ImGuiBackendFlags.HasMouseCursors.int32).ImGuiBackendFlags

  # We can honor io.WantSetMousePos requests (optional, rarely used)
  io.backendFlags = (io.backendFlags.int32 or ImGuiBackendFlags.HasSetMousePos.int32).ImGuiBackendFlags
  io.backendPlatformName = "imgui_impl_sdl"

  # Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
  io.keyMap[ImGuiKey.Tab.int32] = sdl.SCANCODE_TAB.int32
  io.keyMap[ImGuiKey.LeftArrow.int32] = sdl.SCANCODE_LEFT.int32
  io.keyMap[ImGuiKey.RightArrow.int32] = sdl.SCANCODE_RIGHT.int32
  io.keyMap[ImGuiKey.UpArrow.int32] = sdl.SCANCODE_UP.int32
  io.keyMap[ImGuiKey.DownArrow.int32] = sdl.SCANCODE_DOWN.int32
  io.keyMap[ImGuiKey.PageUp.int32] = sdl.SCANCODE_PAGEUP.int32
  io.keyMap[ImGuiKey.PageDown.int32] = sdl.SCANCODE_PAGEDOWN.int32
  io.keyMap[ImGuiKey.Home.int32] = sdl.SCANCODE_HOME.int32
  io.keyMap[ImGuiKey.End.int32] = sdl.SCANCODE_END.int32
  io.keyMap[ImGuiKey.Insert.int32] = sdl.SCANCODE_INSERT.int32
  io.keyMap[ImGuiKey.Delete.int32] = sdl.SCANCODE_DELETE.int32
  io.keyMap[ImGuiKey.Backspace.int32] = sdl.SCANCODE_BACKSPACE.int32
  io.keyMap[ImGuiKey.Space.int32] = sdl.SCANCODE_SPACE.int32
  io.keyMap[ImGuiKey.Enter.int32] = sdl.SCANCODE_RETURN.int32
  io.keyMap[ImGuiKey.Escape.int32] = sdl.SCANCODE_ESCAPE.int32
  io.keyMap[ImGuiKey.KeyPadEnter.int32] = sdl.SCANCODE_KP_ENTER.int32
  io.keyMap[ImGuiKey.A.int32] = sdl.SCANCODE_A.int32
  io.keyMap[ImGuiKey.C.int32] = sdl.SCANCODE_C.int32
  io.keyMap[ImGuiKey.V.int32] = sdl.SCANCODE_V.int32
  io.keyMap[ImGuiKey.X.int32] = sdl.SCANCODE_X.int32
  io.keyMap[ImGuiKey.Y.int32] = sdl.SCANCODE_Y.int32
  io.keyMap[ImGuiKey.Z.int32] = sdl.SCANCODE_Z.int32


  #io.SetClipboardTextFn = igSDL2SetClipboardText  #ImGui_ImplSDL2_SetClipboardText
  #igGetIOio.GetClipboardTextFn = igSDL2GetClipboardText #ImGui_ImplSDL2_GetClipboardText
  io.clipboardUserData = nil

  # Load mouse cursors
  #SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
  gMouseCursors[ImGuiMouseCursor.Arrow.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_ARROW)
  gMouseCursors[ImGuiMouseCursor.TextInput.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_IBEAM)
  gMouseCursors[ImGuiMouseCursor.ResizeAll.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZEALL)
  gMouseCursors[ImGuiMouseCursor.ResizeNS.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENS)
  gMouseCursors[ImGuiMouseCursor.ResizeEW.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZEWE)
  gMouseCursors[ImGuiMouseCursor.ResizeNESW.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENESW)
  gMouseCursors[ImGuiMouseCursor.ResizeNWSE.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENWSE)
  gMouseCursors[ImGuiMouseCursor.Hand.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_HAND)
  gMouseCursors[ImGuiMouseCursor.NotAllowed.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_NO)

  #// Check and store if we are on Wayland
  #g_MouseCanUseGlobalState = strncmp(SDL_GetCurrentVideoDriver(), "wayland", 7) != 0
  # HELP to translate
  when defined(WIN32):
    echo "win32"
  else :
    echo "non win32"
    discard window

  return true


### igSDL2InitForOpenGL - sdlGLcontext ??
proc igSDL2InitForOpenGL*(window: sdl.Window, sdlGLContext: sdl.GLContext ): bool=
  discard sdlGLContext #???? // Viewport branch will need this.
  return igSDL2Init(window)


### igSDL2Shutdown - memset no translate
proc igSDL2Shutdown*() =
  gWindow = nil

  #// Destroy last known clipboard data
  if gClipboardTextData != nil:
    sdl.free(addr gClipboardTextData)
  gClipboardTextData = nil

  #// Destroy SDL mouse cursors
  for i in 0 ..< ImGuiMouseCursor.high.int32 + 1:
    sdl.freeCursor(gMouseCursors[i])
  #memset(g_MouseCursors, 0, sizeof(g_MouseCursors))


### igSDL2UpdateMousePosAndButtons
proc igSDL2UpdateMousePosAndButtons() =
  let io = igGetIO()

  var mouse_x_local, mouse_y_local: cint
  var mouseButtons = sdl.getMouseState(addr mouse_x_local, addr  mouse_y_local)

  for i in 0 ..< 3:
    if gMouseJustPressed[i]:
      echo i, " ", gMouseJustPressed[i]
    io.mouseDown[i] = gMouseJustPressed[i]
    gMouseJustPressed[i] = false

  let mousePosBackup = io.mousePos
  io.mousePos = ImVec2(x: -high(float32), y: -high(float32))

  let focused = true
  if focused:
    if io.wantSetMousePos:
      # XXX ???
      #sdl.warpMouseInWindow(addr gWindow, mousePosBackup.x.cint, mousePosBackup.y.cint)
      discard
    else:
      io.mousePos = ImVec2(x: mouse_x_local.float32, y: mouse_y_local.float32)

### igSDL2UpdateMouseCursor
proc igSDL2UpdateMouseCursor() =
  let io = igGetIO()


### igSDL2UpdateGamepads
proc igSDL2UpdateGamepads() =
  let io = igGetIO()


# igSDL2NewFrame - ok - not tested
proc igSDL2NewFrame*(window : sdl.Window) =
  let io = igGetIO()
  assert io.fonts.isBuilt()

  # Setup display size (every frame to accommodate for window resizing)
  var
    w: int32
    h: int32
    displayW: int32
    displayH: int32

  sdl.getWindowSize(window, w.addr, h.addr)
  if (sdl.getWindowFlags(window) and sdl.WINDOW_MINIMIZED) != 0:
    w = 0
    h = 0

  sdl.glGetDrawableSize(window, displayW.addr, displayH.addr)
  io.displaySize = ImVec2(x: w.float32, y: h.float32)
  if w > 0 and h > 0:
    io.displayFramebufferScale = ImVec2(x: displayW.float32 / w.float32, y: displayH.float32 / h.float32)

  # Setup time step (we don't use SDL_GetTicks() because it is using millisecond resolution)
  var currentTime = getTicks()
  io.deltaTime = if gTime > 0.0f: (currentTime - gTime).float32 else: (1.0f / 60.0f).float32

  gTime = currentTime

  igSDL2UpdateMousePosAndButtons()
  igSDL2UpdateMouseCursor()

  # @TODO: gamepad mapping

