use IO;
use List;

/*
  The numbers come to us in blank-line-separated groups. The easiest way to
  process all of these groups is to keep an intermediate accumulator
  that represents the total number within a group, record that accumulator
  each time we hit an empty line. On the other hand, the last group is
  not terminated by an empty line, so we'd need special logic to handle
  that case. Unless, of course, we just pretended there's an empty line
  at the end, too. We can do this with a custom iterator, `linesWithEnding`.
*/
iter linesWithEnding() {
  for line in stdin.lines() do yield line;
  yield "";
}

/*
  On to the actual intermediate accumulator logic described above. The
  `current` variable will keep the "up-to-this-point" total within a group.
  Whenever we hit an empty line, we know we've finished processing a group,
  so we report the value of `current`. Once again we'll make this logic
  an iterator; each time it finishes up with a group, it will yield the
  group's sum.
*/
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

/*
  At this point, part 1 can be solved simply as:

  ```Chapel
  writeln(max reduce elves());
  ```
*/

/*
  For part 2, I'm going to do something a bit more unusual. Chapel has support
  for reduction expressions, which can even be run in parallel over many
  threads. I'll implement picking the top three elements as a
  custom reduction. If I implement all the methods on this reduction
  class, I'll be able to automatically make my code run on multuple threads!
*/
class MaxThree : ReduceScanOp {
  /* Reductions have an element type, the thing-that's-being-processed.
     This element type is left generic to support reductions over different
     types of things. */
  type eltType;
  /* The value our reduction is building up is a top-three list of the largest
     numbers. This top-three list is represented by a three-element tuple
     of `eltType`, written as `3*eltType`. */
  var value: 3*eltType;

  /* Reductions need an identity element. This is an element that doesn't
     do anything when processed. For instance, for summing, the identity
     element is zero (adding zero to a sum doesn't change the sum). For
     finding a product, the identity element is one (multiplying by one
     leaves the product intact). When finding the _largest_ three numbers
     in a list, the identity element is three [infinums](https://en.wikipedia.org/wiki/Infimum_and_supremum)
     of that list. We'll assume that the default value of the `eltType`
     is its infinum, which means default-initializing a tuple of three
     `eltTypes` will give us such a three-infinum tuple.
   */
  proc identity {
    var val: value.type;
    return val;
  }
  /*
   Next are accumulation functions. These describe how to combine partial
   results from substs of the list of numbers, or how to update the top
   three given a new number. We only need to _really_ implement one version of
   these functions - one that combines two 3-tuples. The rest can be defined
   in terms of that function.
  */
  proc accumulate(x: eltType) { accumulateOntoState(value, x); }
  proc accumulateOntoState(ref state: 3*eltType, x: eltType) { accumulateOntoState(state, (0, 0, x)); }
  proc accumulate(x: 3*eltType) { accumulateOntoState(value, x); }

  /* The accumulation function uses a standard algorithm for merging two sorted
     lists. */
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

  /* The Chapel reduction feature requires a couple of other methods,
     which we implement below. */
  proc clone() return new unmanaged MaxThree(eltType=eltType);
  proc generate() return value;
}

/*
  Let's make it possible to select which part we want to solve from the
  command line. This can be easily achieved via a `config const`. A
  variable like this can be set when running the program from the command
  line as follows:

  ```bash
  ./my-program --part=1
  ```
  */
config const part = 1;

/* Here's how we use our solution. */
if part == 1 {
  /* For part 1, the code remains the same, since we're still just finding
     the one maximum number. */
  writeln(max reduce elves());
} else if part == 2 {
  // Need to read all the numbers into memory to make sure we can distribute
  var elfList = elves();
  writeln(+ reduce (MaxThree reduce elfList));
}

