use IO;
use List;

iter linesWithEnding() {
  for line in stdin.lines() do yield line;
  yield "";
}

iter elves() {
  var current = 0;
  for line in linesWithEnding() {
    const trimmedLine = line.strip();
    if trimmedLine == "" {
      yield current;
      current = 0;
    } else {
      current += trimmedLine : int;
    }
  }
}

class MaxThree : ReduceScanOp {
  type eltType;
  var value: 3*eltType;

  proc identity {
    var val: value.type;
    return val;
  }
  proc accumulate(x: eltType) { accumulateOntoState(value, x); }
  proc accumulateOntoState(ref state: 3*eltType, x: eltType) { accumulateOntoState(state, (0, 0, x)); }
  proc accumulate(x: 3*eltType) { accumulateOntoState(value, x); }

  proc accumulateOntoState(ref state: 3*eltType, x: 3*eltType) {
    var result: state.type;
    var ptr1, ptr2: int = 3-1;
    for param idx in (0..<3 by -1) {
      if x[ptr1] > state[ptr2] {
        result[idx] = x[ptr1];
        ptr1 -= 1;
      } else {
        result[idx] = state[ptr2];
        ptr2 -= 1;
      }
    }
    state = result;
  }
  proc combine(other: MaxThree(eltType)) {
    accumulate(other.value);
  }
  proc clone() return new unmanaged MaxThree(eltType=eltType);
  proc generate() return value;
}

config const part = 1;
config const parallel = false;

if part == 1 {
  writeln(max reduce elves());
} else if part == 2 {
  if parallel {
    writeln(+ reduce (MaxThree reduce elves()));
  } else {
    // Parallel
    var max3 = (0,0,0);
    // Need to read all the numbers into memory to make sure we can distribute
    var elfList = new list(elves());
    // To make a reduction parallel, we use a forall loop with a reduce intent
    forall elf in elfList with (MaxThree(int) reduce max3) {
      max3 reduce= elf;
    }
    writeln(+ reduce max3);
  }
}
