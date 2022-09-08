import csfml
import math


type
  Obstacle* = ref object
    shapes: seq[RectangleShape]
    lines*: seq[array[2, Vector2f]]

proc len*(v: Vector2f): float =
  return sqrt(v.x * v.x + v.y * v.y)

proc angle*(v: Vector2f): float =
  return arctan2(v.y, v.x) - 180f.degToRad

proc new_Obstacle*(points: seq[Vector2f], closed: bool = false): Obstacle =
  var self = Obstacle()
  for i in 0..points.len - 2:
    var pa: Vector2f = points[i]
    var pb: Vector2f = points[i + 1]
    var rect = newRectangleShape()
    rect.size = vec2((pa - pb).len, 1)
    rect.position = pa + vec2(3f, 3f)
    rect.rotation = (pa - pb).angle.radToDeg
    self.shapes.add(rect)
    self.lines.add([pa, pb])
  if closed:
    var pa: Vector2f = points[0]
    var pb: Vector2f = points[points.len - 1]
    var rect = newRectangleShape()
    rect.size = vec2((pa - pb).len, 1)
    rect.position = pa + vec2(3f, 3f)
    rect.rotation = (pa - pb).angle.radToDeg
    self.shapes.add(rect)
    self.lines.add([pa, pb])
  
  return self

proc show*(self: Obstacle, win: RenderWindow) =
  for i, shape in self.shapes:    
    win.draw(shape)

proc move*(self: Obstacle, offset: Vector2f) =
  if offset.x == 0 and offset.y == 0:
    return
  for shape in self.shapes:
    shape.move(offset)

proc destroy*(self: Obstacle) =
  for rect in self.shapes:
    rect.destroy()