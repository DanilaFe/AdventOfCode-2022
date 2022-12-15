use IO, Set, List;

iter data() {
  var x1, y1, x2, y2 = 0;
  while readf("Sensor at x=%i, y=%i: closest beacon is at x=%i, y=%i\n", x1, y1, x2, y2) {
    yield ((x1, y1), (x2, y2), abs(x1-x2) + abs(y1-y2));
  }
}

iter positions((x1,y1), len) {
  for l in 0..len {
    for (dx, dy) in zip(0..l, 0..l by -1) {
      yield (x1+dx, y1+dy);
      yield (x1+dx, y1-dy);
      yield (x1-dx, y1+dy);
      yield (x1-dx, y1-dy);
    }
  }
}

record overlapping {
  var disjoint: list(range(int));

  proc add(arg: range(int)) {
    // Don't pollute `disjoint`.
    if arg.isEmpty() then return;

    var newRng = arg;
    do {
      var merged = false;
      for (rng, i) in zip(disjoint, 0..) {
        if newRng[rng].isEmpty() then continue;
        newRng = min(rng.lowBound, newRng.lowBound)..max(rng.highBound, newRng.highBound);
        disjoint.pop(i);
        merged = true;
        break;
      }
    } while merged;
    disjoint.append(newRng);
  }

  iter these() { for rng in disjoint do yield rng; }
  proc size { return + [rng in this] rng.size; }
  proc boundedSize(bound) { return + reduce [rng in this] rng[bound].size; }
  proc contains(x) { return || reduce [rng in this] rng.contains(x); }
}

enum axis { xAxis = 0, yAxis = 1 };
use axis;

proc ((int, int)).rangeAlong(axs: axis, reach: int, theXOrY: int) {
  const dim = axs : int;
  const dist = abs(this[dim]-theXOrY);

  // Too far
  if dist > reach then return 0..<0;

  // Get the range
  const remDist = max(0, reach-dist);
  return (this[1-dim]-remDist)..(this[1-dim]+remDist);
}


config const theY = 10;
const searchSpace = 0..theY * 2;
const input = data();

// Solve part 1
var overlaps: overlapping;
var occupied: set((int, int));
for (sensor, beacon, reach) in input {
  occupied.add(sensor);
  occupied.add(beacon);
  overlaps.add(sensor.rangeAlong(yAxis, reach, theY));
}
writeln(overlaps.size - (+ reduce [(x,y) in occupied] if y == theY then 1));

// Solve part 2
forall checkY in searchSpace {
  var overlaps: overlapping;
  for (sensor, _, reach) in input {
    overlaps.add(sensor.rangeAlong(yAxis, reach, checkY));
  }

  if overlaps.boundedSize(searchSpace) != searchSpace.size {
    // Found the y-cordinate. Now find the x-coordinate.
    for checkX in searchSpace {
      if !overlaps.contains(checkX) {
        // x-coord isn't in the interval, so we found our answer.
        writeln("x = ", checkX, ", y = ", checkY, ", frequency = ", checkX * 4000000 + checkY);
        break;
      }
    }
  }
}

