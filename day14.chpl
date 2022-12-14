use IO, Set;

proc parseCoord(s: string) {
  const (x, _, y) = s.partition(",");
  return (x : int, y : int);
}

proc (set((int,int))).draw((x1, y1), (x2, y2)) {
  for x in (min(x1,x2)..max(x1,x2)) {
    for y in (min(y1,y2)..max(y1,y2)) {
      this.add((x,y));
    }
  }
}

iter ((int,int)).nextPositions() {
  yield this + (0,1);
  yield this + (-1,1);
  yield this + (1,1);
}

var occupied = new set((int, int));
for line in stdin.lines().strip() {
  const coords = parseCoord(line.split(" -> "));
  for idx in 0..#(coords.size-1) {
    occupied.draw(coords[idx], coords[idx+1]);
  }
}

const maxHeight = max reduce [(x, y) in occupied] y;
const initialPos = (500, 0);
config const hasWall = false;
var grainCount = 0;

do {
  // Start a new grain of sand, but give up if there's already one there.
  var pos = initialPos;
  if occupied.contains(pos) then break;

  // Make the grain fall
  var abyss = false;
  do {
    var moved = false;
    for checkPos in pos.nextPositions() {
      // Check for falling past the floor
      if checkPos[1] > maxHeight + 10 {
        abyss = true;
        break;
      }
      // Try moving, but only if the position is clear and not on the floor.
      if !occupied.contains(checkPos) &&
         !(hasWall && checkPos[1] == maxHeight + 2) {
        pos = checkPos;
        moved = true;
        break;
      }
    }
  } while moved;

  // If we stopped because we fell off, don't count the last grain.
  if !abyss {
    grainCount += 1;
    occupied.add(pos);
  }
} while !abyss;

writeln(grainCount);
