import csfml
import math
import Obstacle

type
  Ray* = ref object
    angle*: float
    max*: float
    last_dist*: float

proc new_Ray*(angle: float, max: float): Ray =
  return Ray(angle: angle, max: max, last_dist: max)

proc get_distance*(self: Ray, origin: Vector2f, segments: seq[array[2,
    Vector2f]]): float =
  var min_dist = self.max
  var this_end = (origin - vec2(cos(self.angle) * self.max, sin(self.angle) * self.max))
  for segment in segments:
    let x1 = segment[0].x
    let x2 = segment[1].x
    let x3 = origin.x
    let x4 = this_end.x
    let y1 = segment[0].y
    let y2 = segment[1].y
    let y3 = origin.y
    let y4 = this_end.y

    let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / ((x1 - x2) * (y3 -
        y4) - (y1 - y2) * (x3 - x4))
    let u = ((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / ((x1 - x2) * (y3 -
        y4) - (y1 - y2) * (x3 - x4))

    if t >= 0 and t <= 1 and u >= 0 and u <= 1:
      var dist = (origin - vec2(x1 + t * (x2 - x1), y1 + t * (y2 - y1))).len
      if dist < min_dist:
        min_dist = dist
  self.last_dist = min_dist
  return min_dist

proc draw*(self: Ray, window: RenderWindow, origin: Vector2f, force: bool = false) =
  # if self.last_dist < self.max or force:
  var rect = newRectangleShape()
  rect.size = vec2(self.last_dist, 1)
  rect.position = origin
  rect.fillColor = color(120, 120, 120, 255)
  rect.rotation = self.angle.radToDeg
  window.draw(rect)
  rect.destroy()
