## # ----------------------------------------------------------------------------
## #
## #  @file       AntTweakBar.h
## #
## #  @brief      AntTweakBar is a light and intuitive graphical user interface 
## #              that can be readily integrated into OpenGL and DirectX 
## #              applications in order to interactively tweak parameters.
## #
## #  @author     Philippe Decaudin
## #
## #  @doc        http://anttweakbar.sourceforge.net/doc
## #
## #  @license    This file is part of the AntTweakBar library.
## #              AntTweakBar is a free software released under the zlib license.
## #              For conditions of distribution and use, see License.txt
## #
## # ----------------------------------------------------------------------------

## # Version Mmm : M=Major mm=minor (e.g., 102 is version 1.02)

const
  TW_VERSION* = 116

## # ----------------------------------------------------------------------------
## #  Bar functions and definitions
## # ----------------------------------------------------------------------------

type
  TwBar* = distinct tuple[]

## # structure CTwBar is not exposed.

proc TwNewBar*(barName: cstring): ptr TwBar {.stdcall, importc: "TwNewBar",
    dynlib: "AntTweakBar".}
proc TwDeleteBar*(bar: ptr TwBar): cint {.stdcall, importc: "TwDeleteBar",
                                     dynlib: "AntTweakBar".}
proc TwDeleteAllBars*(): cint {.stdcall, importc: "TwDeleteAllBars",
                             dynlib: "AntTweakBar".}
proc TwSetTopBar*(bar: ptr TwBar): cint {.stdcall, importc: "TwSetTopBar",
                                     dynlib: "AntTweakBar".}
proc TwGetTopBar*(): ptr TwBar {.stdcall, importc: "TwGetTopBar", dynlib: "AntTweakBar".}
proc TwSetBottomBar*(bar: ptr TwBar): cint {.stdcall, importc: "TwSetBottomBar",
                                        dynlib: "AntTweakBar".}
proc TwGetBottomBar*(): ptr TwBar {.stdcall, importc: "TwGetBottomBar",
                                dynlib: "AntTweakBar".}
proc TwGetBarName*(bar: ptr TwBar): cstring {.stdcall, importc: "TwGetBarName",
    dynlib: "AntTweakBar".}
proc TwGetBarCount*(): cint {.stdcall, importc: "TwGetBarCount", dynlib: "AntTweakBar".}
proc TwGetBarByIndex*(barIndex: cint): ptr TwBar {.stdcall,
    importc: "TwGetBarByIndex", dynlib: "AntTweakBar".}
proc TwGetBarByName*(barName: cstring): ptr TwBar {.stdcall,
    importc: "TwGetBarByName", dynlib: "AntTweakBar".}
proc TwRefreshBar*(bar: ptr TwBar): cint {.stdcall, importc: "TwRefreshBar",
                                      dynlib: "AntTweakBar".}
proc TwGetActiveBar*(): ptr TwBar {.stdcall, importc: "TwGetActiveBar",
                                dynlib: "AntTweakBar".}
## # ----------------------------------------------------------------------------
## #  Var functions and definitions
## # ----------------------------------------------------------------------------

type
  TwType* {.size: sizeof(cint).} = enum
    TW_TYPE_UNDEF = 0, TW_TYPE_BOOLCPP = 1, TW_TYPE_BOOL8 = 2, TW_TYPE_BOOL16,
    TW_TYPE_BOOL32, TW_TYPE_CHAR, TW_TYPE_INT8, TW_TYPE_UINT8, TW_TYPE_INT16,
    TW_TYPE_UINT16, TW_TYPE_INT32, TW_TYPE_UINT32, TW_TYPE_FLOAT, TW_TYPE_DOUBLE, TW_TYPE_COLOR32,
      ## # 32 bits color. Order is RGBA if API is OpenGL or Direct3D10, and inversed if API is
      ## # Direct3D9 (can be modified by defining 'colorOrder=...', see oc)
    TW_TYPE_COLOR3F,          ## # 3 floats color. Order is RGB.
    TW_TYPE_COLOR4F,          ## # 4 floats color. Order is RGBA.
    TW_TYPE_CDSTRING,         ## # Null-terminated C Dynamic String (pointer to an array of char dynamically allocated with malloc/realloc/strdup)
    TW_TYPE_STDSTRING,        ## # don't use this, this is wrong
    TW_TYPE_QUAT4F,           ## # 4 floats encoding a quaternion {qx,qy,qz,qs}
    TW_TYPE_QUAT4D,           ## # 4 doubles encoding a quaternion {qx,qy,qz,qs}
    TW_TYPE_DIR3F,            ## # direction vector represented by 3 floats
    TW_TYPE_DIR3D             ## # direction vector represented by 3 doubles


template TW_TYPE_CSSTRING*(n: int): TwType =
  cast[TwType](0x30000000 + ((n) and 0x0FFFFFFF)) ## # Null-terminated C Static String of size n (defined as char[n], with n<2^28)
  
type
  TwSetVarCallback* = proc (value: pointer; clientData: pointer) {.stdcall.}
  TwGetVarCallback* = proc (value: pointer; clientData: pointer) {.stdcall.}
  TwButtonCallback* = proc (clientData: pointer) {.stdcall.}

proc TwAddVarRW*(bar: ptr TwBar; name: cstring; `type`: TwType; `var`: pointer;
                def: cstring): cint {.stdcall, importc: "TwAddVarRW",
                                   dynlib: "AntTweakBar".}
proc TwAddVarRO*(bar: ptr TwBar; name: cstring; `type`: TwType; `var`: pointer;
                def: cstring): cint {.stdcall, importc: "TwAddVarRO",
                                   dynlib: "AntTweakBar".}
proc TwAddVarCB*(bar: ptr TwBar; name: cstring; `type`: TwType;
                setCallback: TwSetVarCallback; getCallback: TwGetVarCallback;
                clientData: pointer; def: cstring): cint {.stdcall,
    importc: "TwAddVarCB", dynlib: "AntTweakBar".}
proc TwAddButton*(bar: ptr TwBar; name: cstring; callback: TwButtonCallback;
                 clientData: pointer; def: cstring): cint {.stdcall,
    importc: "TwAddButton", dynlib: "AntTweakBar".}
proc TwAddSeparator*(bar: ptr TwBar; name: cstring; def: cstring): cint {.stdcall,
    importc: "TwAddSeparator", dynlib: "AntTweakBar".}
proc TwRemoveVar*(bar: ptr TwBar; name: cstring): cint {.stdcall,
    importc: "TwRemoveVar", dynlib: "AntTweakBar".}
proc TwRemoveAllVars*(bar: ptr TwBar): cint {.stdcall, importc: "TwRemoveAllVars",
    dynlib: "AntTweakBar".}
type
  TwEnumVal* = object
    Value*: cint
    Label*: cstring

  TwStructMember* = object
    Name*: cstring
    Type*: TwType
    Offset*: csize
    DefString*: cstring

  TwSummaryCallback* = proc (summaryString: cstring; summaryMaxLength: csize;
                          value: pointer; clientData: pointer) {.stdcall.}

proc TwDefine*(def: cstring): cint {.stdcall, importc: "TwDefine", dynlib: "AntTweakBar".}
proc TwDefineEnum*(name: cstring; enumValues: ptr TwEnumVal; nbValues: cuint): TwType {.
    stdcall, importc: "TwDefineEnum", dynlib: "AntTweakBar" .}
proc TwDefineEnumFromString*(name: cstring; enumString: cstring): TwType {.stdcall,
    importc: "TwDefineEnumFromString", dynlib: "AntTweakBar".}
proc TwDefineStruct*(name: cstring; structMembers: ptr TwStructMember;
                    nbMembers: cuint; structSize: csize;
                    summaryCallback: TwSummaryCallback; summaryClientData: pointer): TwType {.
    stdcall, importc: "TwDefineStruct", dynlib: "AntTweakBar".}
type
  TwCopyCDStringToClient* = proc (destinationClientStringPtr: cstringArray;
                               sourceString: cstring) {.stdcall.}

proc TwCopyCDStringToClientFunc*(copyCDStringFunc: TwCopyCDStringToClient) {.
    stdcall, importc: "TwCopyCDStringToClientFunc", dynlib: "AntTweakBar".}
proc TwCopyCDStringToLibrary*(destinationLibraryStringPtr: cstringArray;
                             sourceClientString: cstring) {.stdcall,
    importc: "TwCopyCDStringToLibrary", dynlib: "AntTweakBar".}
type
  TwParamValueType* {.size: sizeof(cint).} = enum
    TW_PARAM_INT32, TW_PARAM_FLOAT, TW_PARAM_DOUBLE, TW_PARAM_CSTRING ## # 
                                                                  ## Null-terminated array of char (ie, c-string)


proc TwGetParam*(bar: ptr TwBar; varName: cstring; paramName: cstring;
                paramValueType: TwParamValueType; outValueMaxCount: cuint;
                outValues: pointer): cint {.stdcall, importc: "TwGetParam",
    dynlib: "AntTweakBar".}
proc TwSetParam*(bar: ptr TwBar; varName: cstring; paramName: cstring;
                paramValueType: TwParamValueType; inValueCount: cuint;
                inValues: pointer): cint {.stdcall, importc: "TwSetParam",
                                        dynlib: "AntTweakBar".}
## # ----------------------------------------------------------------------------
## #  Management functions and definitions
## # ----------------------------------------------------------------------------

type
  TwGraphAPI* {.size: sizeof(cint).} = enum
    TW_OPENGL = 1, TW_DIRECT3D9 = 2, TW_DIRECT3D10 = 3, TW_DIRECT3D11 = 4,
    TW_OPENGL_CORE = 5


proc TwInit*(graphAPI: TwGraphAPI; device: pointer): cint {.stdcall, importc: "TwInit",
    dynlib: "AntTweakBar".}
proc TwTerminate*(): cint {.stdcall, importc: "TwTerminate", dynlib: "AntTweakBar".}
proc TwDraw*(): cint {.stdcall, importc: "TwDraw", dynlib: "AntTweakBar".}
proc TwWindowSize*(width: cint; height: cint): cint {.stdcall, importc: "TwWindowSize",
    dynlib: "AntTweakBar".}
proc TwSetCurrentWindow*(windowID: cint): cint {.stdcall,
    importc: "TwSetCurrentWindow", dynlib: "AntTweakBar".}
## # multi-windows support

proc TwGetCurrentWindow*(): cint {.stdcall, importc: "TwGetCurrentWindow",
                                dynlib: "AntTweakBar".}
proc TwWindowExists*(windowID: cint): cint {.stdcall, importc: "TwWindowExists",
    dynlib: "AntTweakBar".}
type
  TwKeyModifier* {.size: sizeof(cint).} = enum
    TW_KMOD_NONE = 0x00000000,  ## # same codes as SDL keysym.mod
    TW_KMOD_SHIFT = 0x00000003, TW_KMOD_CTRL = 0x000000C0, TW_KMOD_ALT = 0x00000100,
    TW_KMOD_META = 0x00000C00
  TwKeySpecial* {.size: sizeof(cint).} = enum
    TW_KEY_BACKSPACE = '\x08', TW_KEY_TAB = '\x09', TW_KEY_CLEAR = 0x0000000C,
    TW_KEY_RETURN = '\x0D', TW_KEY_PAUSE = 0x00000013, TW_KEY_ESCAPE = 0x0000001B,
    TW_KEY_SPACE = ' ', TW_KEY_DELETE = 0x0000007F, TW_KEY_UP = 273, ## # same codes and order as SDL 1.2 keysym.sym
    TW_KEY_DOWN, TW_KEY_RIGHT, TW_KEY_LEFT, TW_KEY_INSERT, TW_KEY_HOME, TW_KEY_END,
    TW_KEY_PAGE_UP, TW_KEY_PAGE_DOWN, TW_KEY_F1, TW_KEY_F2, TW_KEY_F3, TW_KEY_F4,
    TW_KEY_F5, TW_KEY_F6, TW_KEY_F7, TW_KEY_F8, TW_KEY_F9, TW_KEY_F10, TW_KEY_F11,
    TW_KEY_F12, TW_KEY_F13, TW_KEY_F14, TW_KEY_F15, TW_KEY_LAST



proc TwKeyPressed*(key: cint; modifiers: cint): cint {.stdcall,
    importc: "TwKeyPressed", dynlib: "AntTweakBar".}
proc TwKeyTest*(key: cint; modifiers: cint): cint {.stdcall, importc: "TwKeyTest",
    dynlib: "AntTweakBar".}
type
  TwMouseAction* {.size: sizeof(cint).} = enum
    TW_MOUSE_RELEASED, TW_MOUSE_PRESSED
  TwMouseButtonID* {.size: sizeof(cint).} = enum
    TW_MOUSE_LEFT = 1,          ## # same code as SDL_BUTTON_LEFT
    TW_MOUSE_MIDDLE = 2,        ## # same code as SDL_BUTTON_MIDDLE
    TW_MOUSE_RIGHT = 3          ## # same code as SDL_BUTTON_RIGHT



proc TwMouseButton*(action: TwMouseAction; button: TwMouseButtonID): cint {.stdcall,
    importc: "TwMouseButton", dynlib: "AntTweakBar".}
proc TwMouseMotion*(mouseX: cint; mouseY: cint): cint {.stdcall,
    importc: "TwMouseMotion", dynlib: "AntTweakBar".}
proc TwMouseWheel*(pos: cint): cint {.stdcall, importc: "TwMouseWheel",
                                  dynlib: "AntTweakBar".}
proc TwGetLastError*(): cstring {.stdcall, importc: "TwGetLastError",
                               dynlib: "AntTweakBar".}
type
  TwErrorHandler* = proc (errorMessage: cstring) {.stdcall.}

proc TwHandleErrors*(errorHandler: TwErrorHandler) {.stdcall,
    importc: "TwHandleErrors", dynlib: "AntTweakBar".}
## # ----------------------------------------------------------------------------
## #  Helper functions to translate events from some common window management
## #  frameworks to AntTweakBar.
## #  They call TwKeyPressed, TwMouse* and TwWindowSize for you (implemented in
## #  files TwEventWin.c TwEventSDL*.c TwEventGLFW.c TwEventGLUT.c)
## # ----------------------------------------------------------------------------
## # For Windows message proc
## #
## #// Microsoft specific (detection of 64 bits portability issues)
## ##ifndef _W64
## ##   define _W64
## ##endif  // _W64
## ##ifdef _WIN64
## #    int  TwEventWin(void *wnd, unsigned int msg, unsigned __int64 _W64 wParam, __int64 _W64 lParam);
## ##else
## #    int  TwEventWin(void *wnd, unsigned int msg, unsigned int _W64 wParam, int _W64 lParam);
## ##endif
## ##define TwEventWin32    TwEventWin // For compatibility with AntTweakBar versions prior to 1.11
## #
## # For libSDL event loop

proc TwEventSDL*(sdlEvent: pointer; sdlMajorVersion: cuchar; sdlMinorVersion: cuchar): cint {.
    stdcall, importc: "TwEventSDL", dynlib: "AntTweakBar".}
## # For GLFW event callbacks
## # You should define GLFW_CDECL before including AntTweakBar.h if your version of GLFW uses cdecl calling convensions

when defined(GLFW_CDECL):
  proc TwEventMouseButtonGLFWcdecl(glfwButton: cint; glfwAction: cint): cint {.
      cdecl, importc: "TwEventMouseButtonGLFWcdecl", dynlib: "AntTweakBar".}
  proc TwEventKeyGLFWcdecl(glfwKey: cint; glfwAction: cint): cint {.cdecl,
      importc: "TwEventKeyGLFWcdecl", dynlib: "AntTweakBar".}
  proc TwEventCharGLFWcdecl(glfwChar: cint; glfwAction: cint): cint {.cdecl,
      importc: "TwEventCharGLFWcdecl", dynlib: "AntTweakBar".}
  proc TwEventMousePosGLFWcdecl(mouseX: cint; mouseY: cint): cint {.cdecl,
      importc: "TwEventMousePosGLFWcdecl", dynlib: "AntTweakBar".}
  proc TwEventMouseWheelGLFWcdecl(wheelPos: cint): cint {.cdecl,
      importc: "TwEventMouseWheelGLFWcdecl", dynlib: "AntTweakBar".}

  proc TwEventMouseButtonGLFW*(glfwButton: cint; glfwAction: cint): cint =
    TwEventMouseButtonGLFWcdecl(glfwButton, glfwAction)
  proc TwEventKeyGLFWcdecl*(glfwKey: cint; glfwAction: cint): cint =
    TwEventKeyGLFWcdecl(glfwKey, glfwAction)
  proc TwEventCharGLFWcdecl*(glfwChar: cint; glfwAction: cint): cint =
    TwEventCharGLFWcdecl(glfwChar, glfwAction)
  proc TwEventMousePosGLFW*(mouseX: cint; mouseY: cint): cint =
    TwEventMousePosGLFWcdecl(mouseX, mouseY)
  proc TwEventMouseWheelGLFW*(wheelPos: cint): cint =
    TwEventMouseWheelGLFWcdecl(wheelPos)

else:
  proc TwEventMouseButtonGLFW*(glfwButton: cint; glfwAction: cint): cint {.stdcall,
      importc: "TwEventMouseButtonGLFW", dynlib: "AntTweakBar".}
  proc TwEventKeyGLFW*(glfwKey: cint; glfwAction: cint): cint {.stdcall,
      importc: "TwEventKeyGLFW", dynlib: "AntTweakBar".}
  proc TwEventCharGLFW*(glfwChar: cint; glfwAction: cint): cint {.stdcall,
      importc: "TwEventCharGLFW", dynlib: "AntTweakBar".}
  proc TwEventMousePosGLFW*(mouseX: cint; mouseY: cint): cint =
    TwMouseMotion(mouseX, mouseY)
  proc TwEventMouseWheelGLFW*(wheelPos: cint): cint =
    TwMouseWheel(wheelPos)

## # For GLUT event callbacks (Windows calling convention for GLUT callbacks is cdecl)
    
proc TwEventMouseButtonGLUT*(glutButton: cint; glutState: cint; mouseX: cint;
                            mouseY: cint): cint {.cdecl,
    importc: "TwEventMouseButtonGLUT", dynlib: "AntTweakBar".}

proc TwEventMouseMotionGLUT*(mouseX: cint; mouseY: cint): cint {.cdecl,
    importc: "TwEventMouseMotionGLUT", dynlib: "AntTweakBar".}

proc TwEventKeyboardGLUT*(glutKey: cuchar; mouseX: cint; mouseY: cint): cint {.cdecl,
    importc: "TwEventKeyboardGLUT", dynlib: "AntTweakBar".}

proc TwEventSpecialGLUT*(glutKey: cint; mouseX: cint; mouseY: cint): cint {.cdecl,
    importc: "TwEventSpecialGLUT", dynlib: "AntTweakBar".}

proc TwGLUTModifiersFunc*(glutGetModifiersFunc: proc (): cint {.stdcall.}): cint {.
    stdcall, importc: "TwGLUTModifiersFunc", dynlib: "AntTweakBar".}

type
  GLUTmousebuttonfun* = proc (glutButton: cint; glutState: cint; mouseX: cint;
                           mouseY: cint) {.cdecl.}
  
type
  GLUTmousemotionfun* = proc (mouseX: cint; mouseY: cint) {.cdecl.}

type
  GLUTkeyboardfun* = proc (glutKey: cuchar; mouseX: cint; mouseY: cint) {.cdecl.}

type
  GLUTspecialfun* = proc (glutKey: cint; mouseX: cint; mouseY: cint) {.cdecl.}

## # For SFML event loop

proc TwEventSFML*(sfmlEvent: pointer; sfmlMajorVersion: cuchar;
                 sfmlMinorVersion: cuchar): cint {.stdcall, importc: "TwEventSFML",
    dynlib: "AntTweakBar".}
## # For X11 event loop

proc TwEventX11*(xevent: pointer): cint {.stdcall, importc: "TwEventX11",
                                      dynlib: "AntTweakBar".}
