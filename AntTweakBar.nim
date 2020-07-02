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

import std/compilesettings

const TW_VERSION* = 116
when defined(antTweakBarNoNimble) or len(querySettingSeq(nimblePaths)) == 0: # compiled with --noNimblePath
  import os
  proc getAntTweakBarPath(): string {.compileTime.} =
    result = os.parentDir(currentSourcePath())
    echo result
    # "."
else:
  from strutils import strip, splitLines
  proc getAntTweakBarPath(): string {.compileTime.} =
    for line in splitLines(staticExec("nimble path AntTweakBar")):
      # Get the last line and avoid all Hints and Warnings sent to stdout.
      result = line
    result = strip(result)

{.passC: "-I" & getAntTweakBarPath() & "/cAntTweakBar/include" .}
{.passC: "-O3 -Wall -fPIC -fno-strict-aliasing -D__PLACEMENT_NEW_INLINE".}
{.passL: "-lm -lstdc++".}

when defined(windows):
  {.passL: "-lopengl".}
  {.compile: "cAntTweakBar/src/TwEventWin.c".}
  {.compile: "cAntTweakBar/src/TwDirect3D10.cpp".}
  {.compile: "cAntTweakBar/src/TwDirect3D11.cpp".}
  {.compile: "cAntTweakBar/src/TwDirect3D9.cpp".}
else:
  {.passL: "-lGL".}
  {.passL: "-lX11".}
  {.passC: "-I/usr/X11R6/include -D_UNIX".}
  {.compile: "cAntTweakBar/src/TwEventX11.c".}

{.compile: "cAntTweakBar/src/LoadOGL.cpp".}
{.compile: "cAntTweakBar/src/LoadOGLCore.cpp".}
{.compile: "cAntTweakBar/src/TwBar.cpp".}
{.compile: "cAntTweakBar/src/TwColors.cpp".}
{.compile: "cAntTweakBar/src/TwEventGLFW.c".}
{.compile: "cAntTweakBar/src/TwEventGLUT.c".}
{.compile: "cAntTweakBar/src/TwEventSDL.c".}
{.compile: "cAntTweakBar/src/TwEventSDL12.c".}
{.compile: "cAntTweakBar/src/TwEventSDL13.c".}
{.compile: "cAntTweakBar/src/TwEventSDL20.c".}
{.compile: "cAntTweakBar/src/TwEventSFML.cpp".}
{.compile: "cAntTweakBar/src/TwFonts.cpp".}
{.compile: "cAntTweakBar/src/TwMgr.cpp".}
{.compile: "cAntTweakBar/src/TwOpenGL.cpp".}
{.compile: "cAntTweakBar/src/TwOpenGLCore.cpp".}
{.compile: "cAntTweakBar/src/TwPrecomp.cpp".}
#const make_result = staticExec("make -C cAntTweakBar/src")
#const current_dir = staticExec("pwd")
#static:
#  echo "current dir:", current_dir
#  echo make_result
#{.link: "cAntTweakBar/lib/libAntTweakBar.a".}

## # ----------------------------------------------------------------------------
## #  Bar functions and definitions
## # ----------------------------------------------------------------------------

type
  TwBar* = ptr object

## # structure CTwBar is not exposed.

proc TwNewBar*(barName: cstring): TwBar {.importc:"TwNewBar" .}
proc TwDeleteBar*(bar: TwBar): cint {.importc:"TwDeleteBar" .}
proc TwDeleteAllBars*(): cint {.importc: "TwDeleteAllBars".}
proc TwSetTopBar*(bar: TwBar): cint {.importc: "TwSetTopBar".}
proc TwGetTopBar*(): TwBar {.importc: "TwGetTopBar".}
proc TwSetBottomBar*(bar: TwBar): cint {.importc: "TwSetBottomBar".}
proc TwGetBottomBar*(): TwBar {.importc: "TwGetBottomBar".}
proc TwGetBarName*(bar: TwBar): cstring {.importc: "TwGetBarName".}
proc TwGetBarCount*(): cint {.importc: "TwGetBarCount".}
proc TwGetBarByIndex*(barIndex: cint): TwBar {.importc: "TwGetBarByIndex".}
proc TwGetBarByName*(barName: cstring): TwBar {.importc: "TwGetBarByName".}
proc TwRefreshBar*(bar: TwBar): cint {.importc: "TwRefreshBar".}
proc TwGetActiveBar*(): TwBar {.importc: "TwGetActiveBar".}

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
  TwSetVarCallback* = proc (value: pointer; clientData: pointer)
  TwGetVarCallback* = proc (value: pointer; clientData: pointer)
  TwButtonCallback* = proc (clientData: pointer)

proc TwAddVarRW*(bar: TwBar; name: cstring; `type`: TwType; `var`: pointer;
                def: cstring): cint {.importc: "TwAddVarRW".}
proc TwAddVarRO*(bar: TwBar; name: cstring; `type`: TwType; `var`: pointer;
                def: cstring): cint {.importc: "TwAddVarRO".}
proc TwAddVarCB*(bar: TwBar; name: cstring; `type`: TwType;
                setCallback: TwSetVarCallback; getCallback: TwGetVarCallback;
                clientData: pointer; def: cstring): cint {.importc: "TwAddVarCB".}
proc TwAddButton*(bar: TwBar; name: cstring; callback: TwButtonCallback;
                 clientData: pointer; def: cstring): cint {.importc: "TwAddButton".}
proc TwAddSeparator*(bar: TwBar; name: cstring; def: cstring): cint {.importc: "TwAddSeparator".}
proc TwRemoveVar*(bar: TwBar; name: cstring): cint {.importc: "TwRemoveVar".}
proc TwRemoveAllVars*(bar: TwBar): cint {.importc: "TwRemoveAllVars".}
type
  TwEnumVal* = object
    Value*: cint
    Label*: cstring

  TwStructMember* = object
    Name*: cstring
    Type*: TwType
    Offset*: csize_t
    DefString*: cstring

  TwSummaryCallback* = proc (summaryString: cstring; summaryMaxLength: csize_t;
                          value: pointer; clientData: pointer)

proc TwDefine*(def: cstring): cint {.importc: "TwDefine".}
proc TwDefineEnum*(name: cstring; enumValues: ptr TwEnumVal; nbValues: cuint): TwType {.
    importc: "TwDefineEnum" .}
proc TwDefineEnumFromString*(name: cstring; enumString: cstring): TwType {.importc: "TwDefineEnumFromString".}
proc TwDefineStruct*(name: cstring; structMembers: ptr TwStructMember;
                    nbMembers: cuint; structSize: csize_t;
                    summaryCallback: TwSummaryCallback; summaryClientData: pointer): TwType {.
    importc: "TwDefineStruct".}
type
  TwCopyCDStringToClient* = proc (destinationClientStringPtr: cstringArray;
                               sourceString: cstring) {.stdcall.}

proc TwCopyCDStringToClientFunc*(copyCDStringFunc: TwCopyCDStringToClient) {.
    importc: "TwCopyCDStringToClientFunc".}
proc TwCopyCDStringToLibrary*(destinationLibraryStringPtr: cstringArray;
                             sourceClientString: cstring) {.stdcall,
    importc: "TwCopyCDStringToLibrary".}
type
  TwParamValueType* {.size: sizeof(cint).} = enum
    TW_PARAM_INT32, TW_PARAM_FLOAT, TW_PARAM_DOUBLE, TW_PARAM_CSTRING ## #
                                                                  ## Null-terminated array of char (ie, c-string)


proc TwGetParam*(bar: TwBar; varName: cstring; paramName: cstring;
                paramValueType: TwParamValueType; outValueMaxCount: cuint;
                outValues: pointer): cint {.importc: "TwGetParam".}
proc TwSetParam*(bar: TwBar; varName: cstring; paramName: cstring;
                paramValueType: TwParamValueType; inValueCount: cuint;
                inValues: pointer): cint {.importc: "TwSetParam".}
## # ----------------------------------------------------------------------------
## #  Management functions and definitions
## # ----------------------------------------------------------------------------

type
  TwGraphAPI* {.size: sizeof(cint).} = enum
    TW_OPENGL = 1, TW_DIRECT3D9 = 2, TW_DIRECT3D10 = 3, TW_DIRECT3D11 = 4,
    TW_OPENGL_CORE = 5


proc TwInit*(graphAPI: TwGraphAPI; device: pointer): cint {.importc: "TwInit".}
proc TwTerminate*(): cint {.importc: "TwTerminate".}
proc TwDraw*(): cint {.importc: "TwDraw".}
proc TwWindowSize*(width: cint; height: cint): cint {.importc: "TwWindowSize".}
proc TwSetCurrentWindow*(windowID: cint): cint {.importc: "TwSetCurrentWindow".}
## # multi-windows support

proc TwGetCurrentWindow*(): cint {.importc: "TwGetCurrentWindow".}
proc TwWindowExists*(windowID: cint): cint {.importc: "TwWindowExists".}
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



proc TwKeyPressed*(key: cint; modifiers: cint): cint {.importc: "TwKeyPressed".}
proc TwKeyTest*(key: cint; modifiers: cint): cint {.importc: "TwKeyTest".}
type
  TwMouseAction* {.size: sizeof(cint).} = enum
    TW_MOUSE_RELEASED, TW_MOUSE_PRESSED
  TwMouseButtonID* {.size: sizeof(cint).} = enum
    TW_MOUSE_LEFT = 1,          ## # same code as SDL_BUTTON_LEFT
    TW_MOUSE_MIDDLE = 2,        ## # same code as SDL_BUTTON_MIDDLE
    TW_MOUSE_RIGHT = 3          ## # same code as SDL_BUTTON_RIGHT

proc TwMouseButton*(action: TwMouseAction; button: TwMouseButtonID): cint {.
    importc: "TwMouseButton".}

proc TwMouseMotion*(mouseX: cint; mouseY: cint): cint {.importc: "TwMouseMotion".}
proc TwMouseWheel*(pos: cint): cint {.importc: "TwMouseWheel".}
proc TwGetLastError*(): cstring {.importc: "TwGetLastError".}
type
  TwErrorHandler* = proc (errorMessage: cstring)

proc TwHandleErrors*(errorHandler: TwErrorHandler) {.importc: "TwHandleErrors".}
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
    importc: "TwEventSDL".}
## # For GLFW event callbacks
## # You should define GLFW_CDECL before including AntTweakBar.h if your version of GLFW uses cdecl calling convensions

when defined(GLFW_CDECL):
  proc TwEventMouseButtonGLFWcdecl(glfwButton: cint; glfwAction: cint): cint {.
      cdecl, importc: "TwEventMouseButtonGLFWcdecl".}
  proc TwEventKeyGLFWcdecl(glfwKey: cint; glfwAction: cint): cint {.cdecl,
      importc: "TwEventKeyGLFWcdecl".}
  proc TwEventCharGLFWcdecl(glfwChar: cint; glfwAction: cint): cint {.cdecl,
      importc: "TwEventCharGLFWcdecl".}
  proc TwEventMousePosGLFWcdecl(mouseX: cint; mouseY: cint): cint {.cdecl,
      importc: "TwEventMousePosGLFWcdecl".}
  proc TwEventMouseWheelGLFWcdecl(wheelPos: cint): cint {.cdecl,
      importc: "TwEventMouseWheelGLFWcdecl".}

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
  proc TwEventMouseButtonGLFW*(glfwButton: cint; glfwAction: cint): cint {.
      importc: "TwEventMouseButtonGLFW".}
  proc TwEventKeyGLFW*(glfwKey: cint; glfwAction: cint): cint {.
      importc: "TwEventKeyGLFW".}
  proc TwEventCharGLFW*(glfwChar: cint; glfwAction: cint): cint {.
      importc: "TwEventCharGLFW".}
  proc TwEventMousePosGLFW*(mouseX: cint; mouseY: cint): cint =
    TwMouseMotion(mouseX, mouseY)
  proc TwEventMouseWheelGLFW*(wheelPos: cint): cint =
    TwMouseWheel(wheelPos)

## # For GLUT event callbacks (Windows calling convention for GLUT callbacks is cdecl)

proc TwEventMouseButtonGLUT*(glutButton, glutState, mouseX, mouseY: cint): cint
  {.cdecl, importc: "TwEventMouseButtonGLUT".}
proc TwEventMouseMotionGLUT*(mouseX, mouseY: cint): cint
  {.cdecl, importc: "TwEventMouseMotionGLUT".}
proc TwEventKeyboardGLUT*(glutKey: cuchar; mouseX, mouseY: cint): cint
  {.cdecl, importc: "TwEventKeyboardGLUT".}
proc TwEventSpecialGLUT*(glutKey, mouseX, mouseY: cint): cint
  {.cdecl, importc: "TwEventSpecialGLUT".}
proc TwGLUTModifiersFunc*(glutGetModifiersFunc: proc (): cint {.stdcall.}): cint
  {.importc: "TwGLUTModifiersFunc".}

type
  GLUTmousebuttonfun* = proc (glutButton, glutState, mouseX, mouseY: cint) {.cdecl.}
  GLUTmousemotionfun* = proc (mouseX, mouseY: cint) {.cdecl.}
  GLUTkeyboardfun* = proc (glutKey: cuchar; mouseX, mouseY: cint) {.cdecl.}
  GLUTspecialfun* = proc (glutKey, mouseX, mouseY: cint) {.cdecl.}

## # For SFML event loop

proc TwEventSFML*(sfmlEvent: pointer; sfmlMajorVersion: cuchar;
                 sfmlMinorVersion: cuchar): cint {.importc: "TwEventSFML".}
## # For X11 event loop

proc TwEventX11*(xevent: pointer): cint {.importc: "TwEventX11".}
