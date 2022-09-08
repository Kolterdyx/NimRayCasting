import csfml

type
  Screen = ref object
    window: RenderWindow
    width: int
    height: int

proc new_Screen(width: int, height: int, title: string): Screen =
  var screen = Screen(window: new_RenderWindow(video_mode(cint(width), cint(
      height)), title), width: width, height: height)
  return screen

proc destroy(self: Screen) =
  self.window.destroy()
