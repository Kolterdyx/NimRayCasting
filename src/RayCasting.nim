import random
include Screen
include Player
import std/times
import Obstacle
import Map

type
  World = ref object
    screen: Screen
    terrain: seq[Obstacle]

var EXIT = false
var world: World
var player: Player

var delta: float
var old_time: float
var new_time: float

proc setup() =
  randomize()
  world = World(screen: new_Screen(1000, 500, "RayCasting"))
  world.screen.window.mouseCursorGrabbed = true
  world.screen.window.mouseCursorVisible = false
  mouse_setPosition(vec2(100, 100))
  world.terrain.add(new_Obstacle(@[
      vec2(200f, 180f), 
      vec2(320f, 180f), 
      vec2(320f, 320f), 
      vec2(200f, 320f),
      vec2(200f, 280f),
      vec2(280f, 280f),
      vec2(280f, 220f),
      vec2(200f, 220f)
    ], true))
  

  world.terrain.add(new_Obstacle(@[
      vec2(200f, 180f), 
      vec2(30f, 180f), 
      vec2(320f, 20f), 
      vec2(20f, 30f),
      vec2(0f, 80f),
      vec2(80f, 80f),
      vec2(80f, 0f),
      vec2(20f, 50f)
    ], true))
  
  var vertices: seq[Vector2f] = @[]
  var vertc = 8
  var radius = vec2(100f, 100f)
  var offset = vec2(200f, 500f)
  for i in 0..vertc - 1:
    vertices.add(vec2(cos((360f / float(vertc) * float(i)).degToRad) * radius.x + offset.x, sin((360f / float(vertc) * float(i)).degToRad) * radius.y + offset.y))
  world.terrain.add(new_Obstacle(vertices, false))
  vertices = @[]
  vertc = 200
  radius = vec2(100f, 50f)
  offset = vec2(0f, 300f)
  for i in 0..vertc - 1:
    vertices.add(vec2(cos((360f / float(vertc) * float(i)).degToRad) * radius.x + offset.x, sin((360f / float(vertc) * float(i)).degToRad) * radius.y + offset.y))
  world.terrain.add(new_Obstacle(vertices, true))
  player = new_Player(radius = 6, speed = 150, fov = 70)




proc handle_events() =
  var event: Event
  while world.screen.window.poll_event(event):
    case event.kind
      of EventType.Closed:
        world.screen.window.close()
        EXIT = true
      of EventType.KeyPressed:
        case event.key.code
          of KeyCode.Escape:
            world.screen.window.close()
            EXIT = true
          else: discard
      of EventType.MouseWheelScrolled:
        player.fov += 300 * event.mouseWheelScroll.delta * delta
        if player.fov >= 360:
          player.fov = 359
        if player.fov < 1:
          player.fov = 1f
      else: discard

proc map(num: float, old_min: float, old_max: float, new_min: float, new_max: float): float =
  var old_diff = old_max - old_min
  var new_diff = new_max - new_min
  var scale = new_diff / old_diff
  var offset = (-old_diff * scale) + new_diff
  var final = (num * scale) + offset
  return final + new_min

proc draw_3d(ray: Ray, i: float) =
  var rect = newRectangleShape()
  var w = float(world.screen.width) / map(player.fov, 0, 360f, 0, float(player.rays.len)) / 2
  var h = 10000/(-map(ray.last_dist, 0, float(world.screen.width / 2), 0, float(world.screen.height)/2))
  var offset = i * w + float(world.screen.width) / 2
  rect.size = vec2(w, h)
  rect.position = vec2(offset, float(world.screen.height) / 2 - rect.size.y / 2)
  var c = int(255f / (ray.last_dist / 50)).clamp(0, 255)
  rect.fillColor = color(c, c, c, 255)
  world.screen.window.draw(rect)
  rect.destroy()

proc loop() =
  world.screen.window.clear(color(0, 0, 0, 0))
  handle_events()

  new_time = cpuTime()
  delta = old_time - new_time
  old_time = new_time

  player.update(delta, world.terrain)
  player.draw_rays(world.screen.window)
  player.see(world.terrain)

  for obs in world.terrain:
    obs.show(world.screen.window)
  world.screen.window.draw(player.shape)

  var bg = newRectangleShape()
  bg.size = vec2(float(world.screen.width) / 2, float(world.screen.height))
  bg.position = vec2(float(world.screen.width) / 2, 0)
  bg.fillColor = Black
  var div_r = newRectangleShape()
  div_r.size = vec2(1, float(world.screen.height))
  div_r.position = vec2(float(world.screen.width) / 2 - 1, 0)
  world.screen.window.draw(div_r)
  world.screen.window.draw(bg)
  bg.destroy()
  div_r.destroy()
  for i in 0..int(map(player.fov, 0, 360f, 0, float(player.rays.len))) - 1:
    var ray = i + int(map(player.angle - player.fov / 2, 0, 360f, 0, float(player.rays.len)))
    if ray < 0:
      draw_3d(player.rays[player.rays.len - 1 + ray], float(i))
    elif ray >= player.rays.len:
      draw_3d(player.rays[ray - player.rays.len], float(i))
    else:
      draw_3d(player.rays[ray], float(i))

  world.screen.window.display()

proc cleanup() =
  world.screen.destroy()
  for obs in world.terrain:
    obs.destroy()
  player.shape.destroy()

proc main() =
  old_time = cpuTime()
  setup()
  while not EXIT:
    loop()
  cleanup()

when isMainModule:
  main()
