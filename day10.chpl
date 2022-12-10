use IO, Map;

iter ops() {
  for line in stdin.lines().strip() {
    if line == "noop" then {
      yield [0];
    } else {
      const (_, _, n) = line.partition(" ");
      yield [0, n : int];
    }
  }
}

var pc = 1;
var reg = 1;
var state = new map(int, int);
for op in ops() {
  writeln(op);
  for diff in op {
    state[pc] = reg;
    reg += diff;
    pc += 1;
    writeln("State: ", (pc, reg));
  }
}
const indices = 20..220 by 40;
const values = state[indices];
writeln(indices * values);
writeln(+ reduce (indices * values));

var crt: [1..6, 0..<40] bool = false;

for (idx, pc) in zip(crt.domain, 1..) {
  writeln("sprite pos: ", state[pc], " index: ", idx[1]);
  crt[idx] = abs(state[pc] - idx[1]) <= 1;
}

for line in crt.domain.dim(0) {
  writeln([i in crt[line, ..]] if i then '#' else '.');
}
