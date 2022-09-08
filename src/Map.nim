import Obstacle

type
  CubMap* = ref object
    file*: string
    obstacles*: seq[Obstacle]
