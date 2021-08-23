# Copyright 2021, NimGL contributors.

## ImGUI SDL2 Implementation
## ====
## Implementation based on the imgui examples implementations.
## Feel free to use and modify this implementation.
## This needs to be used along with a Renderer.
## 
## Based on : https://github.com/ocornut/imgui/blob/master/backends/imgui_impl_sdl.cpp (2020-05-25)
##
## 
import times
import ../imgui
import sdl2/sdl

# 60 // Data

var
  gWindow: sdl.Window
  gTime: float64 = 0.0f
  gMousePressed: array[3, bool]
  gMouseCursors: array[ImGuiMouseCursor.high.int32 + 1, sdl.Cursor]
  gClipboardTextData: pointer = nil                                     # ???
  gMouseCanUseGlobalState: bool = true

### igSDL2GetClipboardText : OK - Not tested
proc igSDL2GetClipboardText(userData: pointer): cstring {.cdecl.} =
  if gClipboardTextData != nil:
    sdl.free(gClipboardTextData)
  gClipboardTextData = sdl.getClipboardText()
  return cast[cstring](gClipboardTextData)

#[
static const char* ImGui_ImplSDL2_GetClipboardText(void*)
{
    if (g_ClipboardTextData)
        SDL_free(g_ClipboardTextData);
    g_ClipboardTextData = SDL_GetClipboardText();
    return g_ClipboardTextData;
}
]#########################################################################################################



### igSDL2SetClipboardText OK - Not tested
proc igSDL2SetClipboardText(userData: pointer, text: cstring): void {.cdecl.} =
  discard sdl.setClipboardText(text)

#[
static void ImGui_ImplSDL2_SetClipboardText(void*, const char* text)
{
    SDL_SetClipboardText(text);
}
]#########################################################################################################



## You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
## - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
## - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
## Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
## If you have multiple SDL events and some of them are not meant to be used by dear imgui, you may need to filter events based on their windowID field.

proc igSDL2_ProcessEvent(event: sdl.Event): void {.cdecl.} =
  let io = igGetIO()



#[
bool ImGui_ImplSDL2_ProcessEvent(const SDL_Event* event)
{
    ImGuiIO& io = ImGui::GetIO();
    switch (event->type)
    {
    case SDL_MOUSEWHEEL:
        {
            if (event->wheel.x > 0) io.MouseWheelH += 1;
            if (event->wheel.x < 0) io.MouseWheelH -= 1;
            if (event->wheel.y > 0) io.MouseWheel += 1;
            if (event->wheel.y < 0) io.MouseWheel -= 1;
            return true;
        }
    case SDL_MOUSEBUTTONDOWN:
        {
            if (event->button.button == SDL_BUTTON_LEFT) g_MousePressed[0] = true;
            if (event->button.button == SDL_BUTTON_RIGHT) g_MousePressed[1] = true;
            if (event->button.button == SDL_BUTTON_MIDDLE) g_MousePressed[2] = true;
            return true;
        }
    case SDL_TEXTINPUT:
        {
            io.AddInputCharactersUTF8(event->text.text);
            return true;
        }
    case SDL_KEYDOWN:
    case SDL_KEYUP:
        {
            int key = event->key.keysym.scancode;
            IM_ASSERT(key >= 0 && key < IM_ARRAYSIZE(io.KeysDown));
            io.KeysDown[key] = (event->type == SDL_KEYDOWN);
            io.KeyShift = ((SDL_GetModState() & KMOD_SHIFT) != 0);
            io.KeyCtrl = ((SDL_GetModState() & KMOD_CTRL) != 0);
            io.KeyAlt = ((SDL_GetModState() & KMOD_ALT) != 0);
#ifdef _WIN32
            io.KeySuper = false;
#else
            io.KeySuper = ((SDL_GetModState() & KMOD_GUI) != 0);
#endif
            return true;
        }
    }
    return false;
}
]#########################################################################################################


### igSDL2Init : Not finish
proc igSDL2Init(window: sdl.Window): bool =
  gWindow = window

  # Setup backend capabilities flags
  let io = igGetIO()
  io.backendFlags = (io.backendFlags.int32 or ImGuiBackendFlags.HasMouseCursors.int32).ImGuiBackendFlags  #// We can honor GetMouseCursor() values (optional)
  io.backendFlags = (io.backendFlags.int32 or ImGuiBackendFlags.HasSetMousePos.int32).ImGuiBackendFlags   #// We can honor io.WantSetMousePos requests (optional, rarely used)
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
  io.clipboardUserData = nil;

  # Load mouse cursors
  gMouseCursors[ImGuiMouseCursor.Arrow.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_ARROW)     #SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
  gMouseCursors[ImGuiMouseCursor.TextInput.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_IBEAM);
  gMouseCursors[ImGuiMouseCursor.ResizeAll.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZEALL);
  gMouseCursors[ImGuiMouseCursor.ResizeNS.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENS);
  gMouseCursors[ImGuiMouseCursor.ResizeEW.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZEWE);
  gMouseCursors[ImGuiMouseCursor.ResizeNESW.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENESW);
  gMouseCursors[ImGuiMouseCursor.ResizeNWSE.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_SIZENWSE);
  gMouseCursors[ImGuiMouseCursor.Hand.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_HAND);
  gMouseCursors[ImGuiMouseCursor.NotAllowed.int32] = sdl.createSystemCursor(sdl.SYSTEM_CURSOR_NO);

  #// Check and store if we are on Wayland
  #g_MouseCanUseGlobalState = strncmp(SDL_GetCurrentVideoDriver(), "wayland", 7) != 0;
# HELP to translate 
  when defined(WIN32):
    echo "win32"
  else :
    echo "non win32"
    discard window
    
#[
#ifdef _WIN32
  SDL_SysWMinfo wmInfo;
  SDL_VERSION(&wmInfo.version);
  SDL_GetWindowWMInfo(window, &wmInfo);
  io.ImeWindowHandle = wmInfo.info.win.window;
#else
  (void)window;
#endif
]#
  return true

#[
static bool ImGui_ImplSDL2_Init(SDL_Window* window)
{
    g_Window = window;

    // Setup backend capabilities flags
    ImGuiIO& io = ImGui::GetIO();
    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;       // We can honor GetMouseCursor() values (optional)
    io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;        // We can honor io.WantSetMousePos requests (optional, rarely used)
    io.BackendPlatformName = "imgui_impl_sdl";

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
    io.KeyMap[ImGuiKey_Tab] = SDL_SCANCODE_TAB;
    io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
    io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
    io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
    io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
    io.KeyMap[ImGuiKey_PageUp] = SDL_SCANCODE_PAGEUP;
    io.KeyMap[ImGuiKey_PageDown] = SDL_SCANCODE_PAGEDOWN;
    io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
    io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
    io.KeyMap[ImGuiKey_Insert] = SDL_SCANCODE_INSERT;
    io.KeyMap[ImGuiKey_Delete] = SDL_SCANCODE_DELETE;
    io.KeyMap[ImGuiKey_Backspace] = SDL_SCANCODE_BACKSPACE;
    io.KeyMap[ImGuiKey_Space] = SDL_SCANCODE_SPACE;
    io.KeyMap[ImGuiKey_Enter] = SDL_SCANCODE_RETURN;
    io.KeyMap[ImGuiKey_Escape] = SDL_SCANCODE_ESCAPE;
    io.KeyMap[ImGuiKey_KeyPadEnter] = SDL_SCANCODE_KP_ENTER;
    io.KeyMap[ImGuiKey_A] = SDL_SCANCODE_A;
    io.KeyMap[ImGuiKey_C] = SDL_SCANCODE_C;
    io.KeyMap[ImGuiKey_V] = SDL_SCANCODE_V;
    io.KeyMap[ImGuiKey_X] = SDL_SCANCODE_X;
    io.KeyMap[ImGuiKey_Y] = SDL_SCANCODE_Y;
    io.KeyMap[ImGuiKey_Z] = SDL_SCANCODE_Z;

    io.SetClipboardTextFn = ImGui_ImplSDL2_SetClipboardText;
    io.GetClipboardTextFn = ImGui_ImplSDL2_GetClipboardText;
    io.ClipboardUserData = NULL;

    // Load mouse cursors
    g_MouseCursors[ImGuiMouseCursor_Arrow] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_ARROW);
    g_MouseCursors[ImGuiMouseCursor_TextInput] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_IBEAM);
    g_MouseCursors[ImGuiMouseCursor_ResizeAll] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL);
    g_MouseCursors[ImGuiMouseCursor_ResizeNS] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENS);
    g_MouseCursors[ImGuiMouseCursor_ResizeEW] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE);
    g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW);
    g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE);
    g_MouseCursors[ImGuiMouseCursor_Hand] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND);
    g_MouseCursors[ImGuiMouseCursor_NotAllowed] = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_NO);

    // Check and store if we are on Wayland
    g_MouseCanUseGlobalState = strncmp(SDL_GetCurrentVideoDriver(), "wayland", 7) != 0;

#ifdef _WIN32
    SDL_SysWMinfo wmInfo;
    SDL_VERSION(&wmInfo.version);
    SDL_GetWindowWMInfo(window, &wmInfo);
    io.ImeWindowHandle = wmInfo.info.win.window;
#else
    (void)window;
#endif

    return true;
}
]#########################################################################################################


### igSDL2InitForOpenGL - sdlGLcontext ??
proc igSDL2InitForOpenGL*(window: sdl.Window, sdlGLContext: sdl.GLContext ): bool=
  
  discard sdlGLContext #???? // Viewport branch will need this.
  return igSDL2Init(window)

#[
bool ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context)
{
    (void)sdl_gl_context; // Viewport branch will need this.
    return ImGui_ImplSDL2_Init(window);
}#########################################################################################################



bool ImGui_ImplSDL2_InitForVulkan(SDL_Window* window)
{
#if !SDL_HAS_VULKAN
    IM_ASSERT(0 && "Unsupported");
#endif
    return ImGui_ImplSDL2_Init(window);
}#########################################################################################################



bool ImGui_ImplSDL2_InitForD3D(SDL_Window* window)
{
#if !defined(_WIN32)
    IM_ASSERT(0 && "Unsupported");
#endif
    return ImGui_ImplSDL2_Init(window);
}#########################################################################################################

bool ImGui_ImplSDL2_InitForMetal(SDL_Window* window)
{
    return ImGui_ImplSDL2_Init(window);
}
]#########################################################################################################


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
  #memset(g_MouseCursors, 0, sizeof(g_MouseCursors));

#[
void ImGui_ImplSDL2_Shutdown()
{
    g_Window = NULL;

    // Destroy last known clipboard data
    if (g_ClipboardTextData)
        SDL_free(g_ClipboardTextData);
    g_ClipboardTextData = NULL;

    // Destroy SDL mouse cursors
    for (ImGuiMouseCursor cursor_n = 0; cursor_n < ImGuiMouseCursor_COUNT; cursor_n++)
        SDL_FreeCursor(g_MouseCursors[cursor_n]);
    memset(g_MouseCursors, 0, sizeof(g_MouseCursors));
}
]#########################################################################################################


### igSDL2UpdateMousePosAndButtons
proc igSDL2UpdateMousePosAndButtons() =
  let io = igGetIO()


#[
static void ImGui_ImplSDL2_UpdateMousePosAndButtons()
{
    ImGuiIO& io = ImGui::GetIO();

    // Set OS mouse position if requested (rarely used, only when ImGuiConfigFlags_NavEnableSetMousePos is enabled by user)
    if (io.WantSetMousePos)
        SDL_WarpMouseInWindow(g_Window, (int)io.MousePos.x, (int)io.MousePos.y);
    else
        io.MousePos = ImVec2(-FLT_MAX, -FLT_MAX);

    int mx, my;
    Uint32 mouse_buttons = SDL_GetMouseState(&mx, &my);
    io.MouseDown[0] = g_MousePressed[0] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_LEFT)) != 0;  // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
    io.MouseDown[1] = g_MousePressed[1] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_RIGHT)) != 0;
    io.MouseDown[2] = g_MousePressed[2] || (mouse_buttons & SDL_BUTTON(SDL_BUTTON_MIDDLE)) != 0;
    g_MousePressed[0] = g_MousePressed[1] = g_MousePressed[2] = false;

#if SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE && !defined(__EMSCRIPTEN__) && !defined(__ANDROID__) && !(defined(__APPLE__) && TARGET_OS_IOS)
    SDL_Window* focused_window = SDL_GetKeyboardFocus();
    if (g_Window == focused_window)
    {
        if (g_MouseCanUseGlobalState)
        {
            // SDL_GetMouseState() gives mouse position seemingly based on the last window entered/focused(?)
            // The creation of a new windows at runtime and SDL_CaptureMouse both seems to severely mess up with that, so we retrieve that position globally.
            // Won't use this workaround when on Wayland, as there is no global mouse position.
            int wx, wy;
            SDL_GetWindowPosition(focused_window, &wx, &wy);
            SDL_GetGlobalMouseState(&mx, &my);
            mx -= wx;
            my -= wy;
        }
        io.MousePos = ImVec2((float)mx, (float)my);
    }

    // SDL_CaptureMouse() let the OS know e.g. that our imgui drag outside the SDL window boundaries shouldn't e.g. trigger the OS window resize cursor.
    // The function is only supported from SDL 2.0.4 (released Jan 2016)
    bool any_mouse_button_down = ImGui::IsAnyMouseDown();
    SDL_CaptureMouse(any_mouse_button_down ? SDL_TRUE : SDL_FALSE);
#else
    if (SDL_GetWindowFlags(g_Window) & SDL_WINDOW_INPUT_FOCUS)
        io.MousePos = ImVec2((float)mx, (float)my);
#endif
}
]#########################################################################################################



### igSDL2UpdateMouseCursor
proc igSDL2UpdateMouseCursor() =
  let io = igGetIO()

#[
static void ImGui_ImplSDL2_UpdateMouseCursor()
{
    ImGuiIO& io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange)
        return;

    ImGuiMouseCursor imgui_cursor = ImGui::GetMouseCursor();
    if (io.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None)
    {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        SDL_ShowCursor(SDL_FALSE);
    }
    else
    {
        // Show OS mouse cursor
        SDL_SetCursor(g_MouseCursors[imgui_cursor] ? g_MouseCursors[imgui_cursor] : g_MouseCursors[ImGuiMouseCursor_Arrow]);
        SDL_ShowCursor(SDL_TRUE);
    }
}
]#########################################################################################################



### igSDL2UpdateGamepads
proc igSDL2UpdateGamepads() = 
  let io = igGetIO()
#[
static void ImGui_ImplSDL2_UpdateGamepads()
{
    ImGuiIO& io = ImGui::GetIO();
    memset(io.NavInputs, 0, sizeof(io.NavInputs));
    if ((io.ConfigFlags & ImGuiConfigFlags_NavEnableGamepad) == 0)
        return;

    // Get gamepad
    SDL_GameController* game_controller = SDL_GameControllerOpen(0);
    if (!game_controller)
    {
        io.BackendFlags &= ~ImGuiBackendFlags_HasGamepad;
        return;
    }

    // Update gamepad inputs
    #define MAP_BUTTON(NAV_NO, BUTTON_NO)       { io.NavInputs[NAV_NO] = (SDL_GameControllerGetButton(game_controller, BUTTON_NO) != 0) ? 1.0f : 0.0f; }
    #define MAP_ANALOG(NAV_NO, AXIS_NO, V0, V1) { float vn = (float)(SDL_GameControllerGetAxis(game_controller, AXIS_NO) - V0) / (float)(V1 - V0); if (vn > 1.0f) vn = 1.0f; if (vn > 0.0f && io.NavInputs[NAV_NO] < vn) io.NavInputs[NAV_NO] = vn; }
    const int thumb_dead_zone = 8000;           // SDL_gamecontroller.h suggests using this value.
    MAP_BUTTON(ImGuiNavInput_Activate,      SDL_CONTROLLER_BUTTON_A);               // Cross / A
    MAP_BUTTON(ImGuiNavInput_Cancel,        SDL_CONTROLLER_BUTTON_B);               // Circle / B
    MAP_BUTTON(ImGuiNavInput_Menu,          SDL_CONTROLLER_BUTTON_X);               // Square / X
    MAP_BUTTON(ImGuiNavInput_Input,         SDL_CONTROLLER_BUTTON_Y);               // Triangle / Y
    MAP_BUTTON(ImGuiNavInput_DpadLeft,      SDL_CONTROLLER_BUTTON_DPAD_LEFT);       // D-Pad Left
    MAP_BUTTON(ImGuiNavInput_DpadRight,     SDL_CONTROLLER_BUTTON_DPAD_RIGHT);      // D-Pad Right
    MAP_BUTTON(ImGuiNavInput_DpadUp,        SDL_CONTROLLER_BUTTON_DPAD_UP);         // D-Pad Up
    MAP_BUTTON(ImGuiNavInput_DpadDown,      SDL_CONTROLLER_BUTTON_DPAD_DOWN);       // D-Pad Down
    MAP_BUTTON(ImGuiNavInput_FocusPrev,     SDL_CONTROLLER_BUTTON_LEFTSHOULDER);    // L1 / LB
    MAP_BUTTON(ImGuiNavInput_FocusNext,     SDL_CONTROLLER_BUTTON_RIGHTSHOULDER);   // R1 / RB
    MAP_BUTTON(ImGuiNavInput_TweakSlow,     SDL_CONTROLLER_BUTTON_LEFTSHOULDER);    // L1 / LB
    MAP_BUTTON(ImGuiNavInput_TweakFast,     SDL_CONTROLLER_BUTTON_RIGHTSHOULDER);   // R1 / RB
    MAP_ANALOG(ImGuiNavInput_LStickLeft,    SDL_CONTROLLER_AXIS_LEFTX, -thumb_dead_zone, -32768);
    MAP_ANALOG(ImGuiNavInput_LStickRight,   SDL_CONTROLLER_AXIS_LEFTX, +thumb_dead_zone, +32767);
    MAP_ANALOG(ImGuiNavInput_LStickUp,      SDL_CONTROLLER_AXIS_LEFTY, -thumb_dead_zone, -32767);
    MAP_ANALOG(ImGuiNavInput_LStickDown,    SDL_CONTROLLER_AXIS_LEFTY, +thumb_dead_zone, +32767);

    io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
    #undef MAP_BUTTON
    #undef MAP_ANALOG
}
]########################################################################################################

proc getTicks(): float64 =
  let curTime = times.getTime()
  result = curTime.toUnix().float64 + curTime.nanosecond() / 1000000000

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

  # Update game controllers (if enabled and available)
  # XXX todo
  # igSDL2UpdateGamepads()

#[
void ImGui_ImplSDL2_NewFrame(SDL_Window* window)
{
    ImGuiIO& io = ImGui::GetIO();
    IM_ASSERT(io.Fonts->IsBuilt() && "Font atlas not built! It is generally built by the renderer backend. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame().");

    // Setup display size (every frame to accommodate for window resizing)
    int w, h;
    int display_w, display_h;
    SDL_GetWindowSize(window, &w, &h);
    if (SDL_GetWindowFlags(window) & SDL_WINDOW_MINIMIZED)
        w = h = 0;
    SDL_GL_GetDrawableSize(window, &display_w, &display_h);
    io.DisplaySize = ImVec2((float)w, (float)h);
    if (w > 0 && h > 0)
        io.DisplayFramebufferScale = ImVec2((float)display_w / w, (float)display_h / h);

    // Setup time step (we don't use SDL_GetTicks() because it is using millisecond resolution)
    static Uint64 frequency = SDL_GetPerformanceFrequency();
    Uint64 current_time = SDL_GetPerformanceCounter();
    io.DeltaTime = g_Time > 0 ? (float)((double)(current_time - g_Time) / frequency) : (float)(1.0f / 60.0f);
    g_Time = current_time;

    ImGui_ImplSDL2_UpdateMousePosAndButtons();
    ImGui_ImplSDL2_UpdateMouseCursor();

    // Update game controllers (if enabled and available)
    ImGui_ImplSDL2_UpdateGamepads();
}

]#########################################################################################################
