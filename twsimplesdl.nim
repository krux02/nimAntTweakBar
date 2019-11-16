## A simple example that uses AntTweakBar with OpenGL 1.4 and SDL 2.0

import sdl2/sdl
import AntTweakBar
import opengl
import math

proc main(): int =
  #var video: sdl.VideoInfo = nil
  var
    width  = 640'i32
    height = 480'i32
    flags  = 0'i32

  var quit = false;
  var bar: TwBar
  var n = 0
  var numCubes = 30'i32
  var color0 = [1.0'f32, 0.5'f32, 0.0'f32]
  var color1 = [0.5'f32, 1.0'f32, 0.0'f32]
  var ka = 5.3
  var kb = 1.7
  var kc = 4.1

  if sdl.init(sdl.INIT_EVERYTHING) < 0:
    stderr.writeLine("Video initialization failed: ", sdl.getError())
    sdl.quit()
    return 1


  doAssert 0 == sdl.glSetAttribute(GL_CONTEXT_MAJOR_VERSION, 1)
  doAssert 0 == sdl.glSetAttribute(GL_CONTEXT_MINOR_VERSION, 4)


  let window = sdl.createWindow(
    "AntTweakBar simple example using SDL",
    sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED,
    width, height, WINDOW_OPENGL or WINDOW_RESIZABLE
  )

  let context = window.glCreateContext()
  if context == nil:
    stderr.writeLine("OpenGL context creation failed: ", sdl.getError())
    sdl.quit()
    return 1

  loadExtensions()

  # Set OpenGL viewport and states
  glViewport(0, 0, width, height)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_LIGHTING)
  glEnable(GL_LIGHT0) # use default light diffuse and position
  glEnable(GL_NORMALIZE)
  glEnable(GL_COLOR_MATERIAL)
  glDisable(GL_CULL_FACE)
  glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE)

  # Initialize AntTweakBar
  discard TwInit(TW_OPENGL, nil)

  # Tell the window size to AntTweakBar
  discard TwWindowSize(width, height)

  # Create a tweak bar
  bar = TwNewBar("TweakBar")
  discard TwDefine(" GLOBAL help='This example shows how to integrate AntTweakBar with SDL and OpenGL.\nPress [Space] to toggle fullscreen.' ") # Message added to the help bar.

  # Add 'width' and 'height' to 'bar': they are read-only (RO) variables of type TW_TYPE_INT32.
  discard TwAddVarRO(bar, "Width", TW_TYPE_INT32, addr(width),
             " label='Wnd width' help='Width of the graphics window (in pixels)' ")

  discard TwAddVarRO(bar, "Height", TW_TYPE_INT32, addr(height),
             " label='Wnd height' help='Height of the graphics window (in pixels)' ")

  # Add 'numCurves' to 'bar': this is a modifiable variable of type TW_TYPE_INT32. Its shortcuts are [c] and [C].
  discard TwAddVarRW(bar, "NumCubes", TW_TYPE_INT32, addr(numCubes),
             " label='Number of cubes' min=1 max=100 keyIncr=c keyDecr=C help='Defines the number of cubes in the scene.' ")

  # Add 'ka', 'kb and 'kc' to 'bar': they are modifiable variables of type TW_TYPE_DOUBLE
  discard TwAddVarRW(bar, "ka", TW_TYPE_DOUBLE, addr(ka),
             " label='X path coeff' keyIncr=1 keyDecr=CTRL+1 min=-10 max=10 step=0.01 ")
  discard TwAddVarRW(bar, "kb", TW_TYPE_DOUBLE, addr(kb),
             " label='Y path coeff' keyIncr=2 keyDecr=CTRL+2 min=-10 max=10 step=0.01 ")
  discard TwAddVarRW(bar, "kc", TW_TYPE_DOUBLE, addr(kc),
             " label='Z path coeff' keyIncr=3 keyDecr=CTRL+3 min=-10 max=10 step=0.01 ")

  # Add 'color0' and 'color1' to 'bar': they are modifable variables of type TW_TYPE_COLOR3F (3 floats color)
  discard TwAddVarRW(bar, "color0", TW_TYPE_COLOR3F, addr(color0),
             " label='Start color' help='Color of the first cube.' ")
  discard TwAddVarRW(bar, "color1", TW_TYPE_COLOR3F, addr(color1),
             " label='End color' help='Color of the last cube. Cube colors are interpolated between the Start and End colors.' ")

  # Add 'quit' to 'bar': this is a modifiable (RW) variable of type TW_TYPE_BOOL32
  # (a boolean stored in a 32 bits integer). Its shortcut is [ESC].
  discard TwAddVarRW(bar, "Quit", TW_TYPE_BOOL8, addr(quit),
             " label='Quit?' true='+' false='-' key='ESC' help='Quit program.' ")

  # Main loop:
  # - Draw some cubes
  # - Process events
  while not quit:
      var handled: int32

      # Clear screen
      glClearColor(0.5f, 0.75f, 0.8f, 1)
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

      # Set OpenGL camera
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity()
      #gluPerspective(40, (double)width/height, 1, 10)
      glFrustum(-width/height, width/height, -1, 1, 1, 10)
      #gluLookAt(0,0,3, 0,0,0, 0,1,0)
      glTranslated(0, 0, -3)

      # Draw cubes
      for n in 0 ..< numCubes:
          let t = 0.05*float64(n) - float64(sdl.getTicks())/2000.0
          let r = 5.0*float64(n) + float64(sdl.getTicks())/10.0
          let c = (float)n/numCubes

          # Set cube position
          glMatrixMode(GL_MODELVIEW)
          glLoadIdentity()
          glTranslated(0.6*cos(ka*t), 0.6*cos(kb*t), 0.6*sin(kc*t))
          glRotated(r, 0.2, 0.7, 0.2)
          glScaled(0.1, 0.1, 0.1)
          glTranslated(-0.5, -0.5, -0.5)

          # Set cube color
          glColor3f((1.0f-c)*color0[0]+c*color1[0], (1.0f-c)*color0[1]+c*color1[1], (1.0f-c)*color0[2]+c*color1[2])

          # Draw cube
          glBegin(GL_QUADS)
          glNormal3f(0,0,-1); glVertex3f(0,0,0); glVertex3f(0,1,0); glVertex3f(1,1,0); glVertex3f(1,0,0); # front face
          glNormal3f(0,0,+1); glVertex3f(0,0,1); glVertex3f(1,0,1); glVertex3f(1,1,1); glVertex3f(0,1,1); # back face
          glNormal3f(-1,0,0); glVertex3f(0,0,0); glVertex3f(0,0,1); glVertex3f(0,1,1); glVertex3f(0,1,0); # left face
          glNormal3f(+1,0,0); glVertex3f(1,0,0); glVertex3f(1,1,0); glVertex3f(1,1,1); glVertex3f(1,0,1); # right face
          glNormal3f(0,-1,0); glVertex3f(0,0,0); glVertex3f(1,0,0); glVertex3f(1,0,1); glVertex3f(0,0,1); # bottom face
          glNormal3f(0,+1,0); glVertex3f(0,1,0); glVertex3f(0,1,1); glVertex3f(1,1,1); glVertex3f(1,1,0); # top face
          glEnd()


      # Draw tweak bars
      discard TwDraw()

      # Present frame buffer
      window.glSwapWindow()

      # Process incoming events
      for event in sdl.events():
          # Send event to AntTweakBar
          handled = TwEventSDL(cast[pointer](unsafeAddr(event)), cuchar(sdl.MAJOR_VERSION), cuchar(sdl.MINOR_VERSION))

          # If event has not been handled by AntTweakBar, process it
          if handled == 0:
              case event.kind:
              of sdl.QUIT:  # Window is closed
                  quit = true

              of sdl.WINDOWEVENT:   # Window size has changed
                if event.window.event == sdl.WINDOWEVENT_RESIZED:
                  # Resize SDL video mode

                  width = event.window.data1
                  height = event.window.data2

                  # Resize OpenGL viewport
                  glViewport(0, 0, width, height)

                  # TwWindowSize has been called by TwEventSDL,
                  # so it is not necessary to call it again here.

              of KEYDOWN:
                  if event.key.keysym.scancode == SCANCODE_SPACE: # toggle fullscreen if Space key is pressed
                    if (sdl.getWindowFlags(window) and sdl.WINDOW_FULLSCREEN_DESKTOP) == 0:
                      discard setWindowFullscreen(window, sdl.WINDOW_FULLSCREEN_DESKTOP)
                    else:
                      discard setWindowFullscreen(window, 0)
              else:
                discard
  # End of main loop

  # Terminate AntTweakBar
  discard TwTerminate();

  # Terminate SDL
  sdl.quit();

  return 0;


quit(main())
