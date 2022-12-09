use IO, Set;

const moveList = [ "L" => (-1, 0), "R" => (1, 0), "U" => (0, 1), "D" => (0, -1) ];

iter moves() {
  for line in stdin.lines().strip() {
    const (dir, _, n) = line.partition(" ");
    yield (moveList[dir], n : int);
  }
}

config const length = 2;
var rope: [0..<length] (int, int) = (0, 0);

proc move((hx, hy), (tx, ty)): (int, int) {
  const (dx, dy) = (hx - tx, hy - ty);
  if abs(dx) > 1 && dy == 0 {
    tx += sgn(dx);
  } else if abs(dy) > 1 && dx == 0 {
    ty += sgn(dy);
  } else if abs(dx) + abs(dy) > 2 {
    tx += sgn(dx);
    ty += sgn(dy);
  }
  return (tx, ty);
}

var visited = new set((int, int));

for (delta, n) in moves() {
  for 1..n {
    rope[0] += delta;
    for idx in 1..<length {
      rope[idx] = move(rope[idx-1], rope[idx]);
    }
    visited.add(rope.last);
  }
}
writeln(visited.size);
