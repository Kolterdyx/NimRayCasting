import csfml
import Ray
import math
import Obstacle

type
  Player = ref object
    position: Vector2f
    radius: float
    shape: CircleShape
    rays: array[2000, Ray]
    speed: float
    fov: float
    angle: float
    lastMouseMove: Vector2i

proc new_Player(radius: float = 5, speed: float = 100, fov: float = 70): Player =
  var self = Player(position: vec2(250, 250), radius: radius)
  self.speed = speed
  self.fov = fov
  self.shape = newCircleShape()
  self.shape.fillColor = color(255, 255, 255, 255)
  self.shape.radius = self.radius
  self.shape.position = self.position - vec2(self.radius / 2, self.radius / 2)
  for i in 0..self.rays.len - 1:
    self.rays[i] = new_Ray(float(i * 360 / self.rays.len).degToRad, 10000)
  return self

proc update(self: Player, delta: float, obstacles: seq[Obstacle]) =
  var vel = vec2(0f, 0f)
  var speed = self.speed
  if keyboard_isKeyPressed(KeyCode.LShift):
    speed *= 2f
  if keyboard_isKeyPressed(KeyCode.W):
    vel = -vec2(cos(self.angle.degToRad) * speed * delta, sin(self.angle.degToRad) * speed * delta)
  if keyboard_isKeyPressed(KeyCode.S):
    vel = vec2(cos(self.angle.degToRad) * speed * delta, sin(self.angle.degToRad) * speed * delta)
  if keyboard_isKeyPressed(KeyCode.A):
    vel = vec2(cos(self.angle.degToRad) * speed * delta, sin(self.angle.degToRad) * speed * delta)
    vel = vec2(-vel.y, vel.x)
  if keyboard_isKeyPressed(KeyCode.D):
    vel = vec2(cos(self.angle.degToRad) * speed * delta, sin(self.angle.degToRad) * speed * delta)
    vel = -vec2(-vel.y, vel.x)
  
  self.position = self.position + vel
  for obs in obstacles:
    obs.move(-vel)

  if mouse_getPosition().x - self.lastMouseMove.x < 0:
    self.angle += float(abs(mouse_getPosition().x - self.lastMouseMove.x) * 10) * delta
    if self.angle <= 0:
      self.angle += 360
    mouse_setPosition(vec2(100, 100))
  if mouse_getPosition().x - self.lastMouseMove.x > 0:
    self.angle -= float(abs(mouse_getPosition().x - self.lastMouseMove.x) * 10) * delta
    if self.angle >= 360:
      self.angle -= 360
    mouse_setPosition(vec2(100, 100))
  self.lastMouseMove = mouse_getPosition()
  

proc isInAngleRange(angle: float, a: float, b: float): bool =
  var N = int(angle) mod 360
  var A = int(a) mod 360
  var B = int(b) mod 360
  if A < B:
    return A <= N and N <= B
  return A <= N or N <= B

proc draw_rays(self: Player, window: RenderWindow) =
  for ray in self.rays:
    var angle = ray.angle.radToDeg + self.fov / 2
    if not angle.isInAngleRange(self.angle, self.angle + self.fov):
      continue
    ray.draw(window, self.shape.position + vec2(self.radius, self.radius))
  
  var lim1 = new_Ray((self.angle - self.fov/2).degToRad, 20)
  var lim2 = new_Ray((self.angle + self.fov/2).degToRad, 20)
  var dir = new_Ray(self.angle.degToRad, 20)

  lim1.draw(window, self.shape.position + vec2(self.radius, self.radius), true)
  lim2.draw(window, self.shape.position + vec2(self.radius, self.radius), true)
  dir.draw(window, self.shape.position + vec2(self.radius, self.radius), true)


proc see(self:Player, obstacles: seq[Obstacle]) =
  var lines: seq[array[2, Vector2f]] = @[]
  for obs in obstacles:
    for line in obs.lines:
      lines.add(line)
  for ray in self.rays:
    discard ray.get_distance(self.position, lines)