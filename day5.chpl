use List;
use IO;

iter boxes() {
  for line in stdin.lines() {
    if line == "\n" then return;
    var boxList = new list(string);

    for idx in 0..<line.size by 4 align 1 {
      boxList.append(line[idx]);
    }
    yield boxList;
  }
}

iter instructions() {
  var n, from, to: int;
  while readf("move %i from %i to %i\n", n, from, to) do yield (n, from-1, to-1);
}

proc transpose(lists) {
  var listsT: [0..<lists[0].size] list(string);
  for lidx in 0..<(lists.size - 1) by -1 {
    for (char, idx) in zip(lists[lidx], 0..) {
      if char != ' ' then listsT[idx].append(char);
    }
  }
  return listsT;
}

proc moveOneAtATime(ref from: list(string), ref to: list(string), n: int) {
  for i in 1..n {
    to.append(from.pop());
  }
}

proc moveAll(ref from: list(string), ref to: list(string), n: int) {
  var offset = from.size - n;
  for i in 1..n {
    to.append(from.pop(offset));
  }
}

proc tops(stacks) {
  var acc = "";
  for stack in stacks do acc += stack.last();
  return acc;
}

var layers = boxes();
var stacks = transpose(layers);

config const part = 1;

if part == 1 {
  for (n, from, to) in instructions() {
    moveOneAtATime(stacks[from], stacks[to], n);
  }
} else if part == 2 {
  for (n, from, to) in instructions() {
    moveAll(stacks[from], stacks[to], n);
  }
}
writeln(tops(stacks));
