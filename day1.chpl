// Advent of Code 2022, Day 1: Counting Calories, Daniel's Take
// tags: ["Advent of Code 2022", "Parallel Programming", "Debugging"]
// summary: "Daniel's take on day 1 of advent of code, featuring reduce expressions, iterators, and custom reductions"
// authors: ["Daniel Fedorin"]
// date: 2022-12-01
// draft: true

/*
  And so Advent of Code begins! Today's challenge is, as usual for the first
  day, a fairly easy one. Brad has [already written]({{< relref "aoc2022-day01-calories" >}}) a wonderful introduction for
  this challenge, and provided his own solution to the first part. In that
  article, Brad is careful to not use too many complicated or unstable features,
  and makes sure that they are well explained. I, on the other hand, am
  quite excited about a few fancier features of Chapel, and already have a few
  in mind for this day's programming challenge. Let's give them a go!

  First things first, though -- we need to be able to read our puzzle input.
  To this end, let's `use` the `IO` module.
*/
use IO;

/*

  ### Iterators and Injecting an Extra Line

  The numbers come to us in blank-line-separated groups. The easiest way to
  process all of these groups is to keep an intermediate accumulator
  that represents the total number within a group, and report that accumulator
  each time we hit an empty line.

  On the other hand, the last group is not terminated by an empty line, so we
  can't _just_ look at the accumulator whenever we see an empty line. If
  we did, we'd forget the last elf! We could add another condition checking
  for the end-of-file (which is what Brad does), but what if we just
  added an empty line at the end? That would solve our problem, too.

  The [`channel`](https://chapel-lang.org/docs/modules/standard/IO.html#IO.channel)
  data type in Chapel's `IO` module (of which `stdin`, the input stream,
  is one example) provides a method called [`lines`](https://chapel-lang.org/docs/modules/standard/IO.html#IO.channel.lines).
  This method creates an _iterator_. Simply put, an iterator gives you data
  (like `string`s representing the lines of a file!) one at a time. It can
  be used in combination with a `for` loop like this:

  ```Chapel
  for item in theIterator do writeln(item)
  ```

  The above loop will print each of the items that the iterator will give to
  it. In our particular case, the above could be specialized to:

  ```Chapel
  for line in stdin.lines() do writeln(line)
  ```

  This would simply print the input stream back out to the console. Alas,
  there's no way to add to the end of an iterator, which is what we seem
  to want to do with that "last empty line" idea. What we can do, though,
  is make a new iterator. In Chapel, we can create custom iterators using
  the `iter` keyword, followed by the name of our new iterator. Just
  like a Chapel [procedure](https://chapel-lang.org/docs/language/spec/procedures.html),
  this iterator can accept arguments. Since we're _making_ the iterator, it
  is our responsibility now to "give" items -- we do this using the `yield`
  keyword. For instance, we could make a simple iterator that gives
  the numbers `1`, then `2`, then `3`:

  ```Chapel
  iter giveOneTwoThree() {
    yield 1;
    yield 2;
    yield 3;
  }

  // will print 1, 2, 3, each on a new line.
  for i in giveOneTwoThree() do writeln(i);
  ```

  So to make our new iterator that gives all the lines in the file, and
  then one more blank one, we can first use a `for` loop and forward
  all the lines from the `stdin.lines()` iterator, and the just yield
  once more, giving that last empty line.
*/
iter linesWithEnding() {
  for line in stdin.lines() do yield line;
  yield "";
}

/*
  That was a lot of background, but as you can see, the actual implementation
  is only 4 lines long.

  ### Computing Calories per Elf

  On to the actual intermediate accumulator logic described above. We'll have
  a `current` variable that will keep the running total of the calories in
  the current elf's snacks. Whenever we hit an empty line, we know we've
  finished processing a group, so we report the value of `current`. Once again
  we'll make this logic an iterator; each time it finishes up with a group, it
  will yield the group's sum.
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

  ### Reductions

  If we printed each item from this iterator, it would give us the total
  calories for each of the elves, one at a time.

  Another cool feature of Chapel is [reductions](https://chapel-lang.org/docs/primers/reductions.html).
  A reduction can combine all of the items in an iterator or array using some kind
  of operation. For example, `+ reduce [1,2,3,4]` will sum the numbers one
  through four, giving 10. Another example is `* reduce (1..n)`, which computes
  the factorial of `n` (where the factorial of a number $n$, aka
  $n!$, is defined as $n! = 1\times 2\times ... \times n$). Another operation
  that Chapel reductions support is `max`, or computing the maximum.

  At this point, part 1 can be solved simply as:

  ```Chapel
  writeln(max reduce elves());
  ```

  We could stop here, if we wanted. However, so far, none of this has _really_
  showcased the "special" features of Chapel. Iterators are cool, but also
  a thing in Python (and many other languages). Lots of languages have some
  form of reduction,
  {{< sidenote "right" "reduce-note" "though perhaps not as convenient." >}}
  For instance, in Haskell, one might write <code>foldr max 0 array</code>.
  In JavaScript, you could do something very similar, using <code>reduce</code>.
  In <a href="https://www.jsoftware.com/#/">J</a>,
  you could just write <code>>./array</code> and get its maximum value.
  {{< /sidenote >}}
  What makes Chapel cool, though, is its natural support for parallelism.
  Its one-sentence summary is, after all,
  > Chapel is a programming language designed for productive parallel computing at scale.

  Well, it so happens that reductions can be parallelized, automatically.
  Chapel can spread the computation across multiple threads, and combine
  the results, all without our intervention. You might be wondering,
  is it happening now? Did we write our first parallel solution to an Advent
  of Code puzzle?

  ### Debugging Parallel Execution

  Confirming that we're running in parallel is a little bit tricky. There are a
  couple of compile-time flags we can enable to print out parallelism statistics,
  and as far as I can tell, they are not documented in many places. Here they
  are:

  ```bash
  -sdebugDataPar=true -sdebugDefaultDist=true
  ```

  So, what do we get? The output is in the (hidden-by-default) block below.
  {{< details summary="(program output with just our iterator...)" >}}
  ```
  *** DR alloc locale 0
  *** DR calling postalloc locale 0
  *** DR alloc locale 1
  *** DR calling postalloc locale 1
  *** DR alloc locale 1
  *** DR calling postalloc locale 1
  <puzzle answer>
  *** In defRectArr simple-dd serial iterator
  *** DR calling dealloc locale
  *** In defRectArr simple-dd serial iterator
  *** DR calling dealloc locale
  *** DR calling dealloc locale
  ```
  {{< /details >}}

  It's a lot of output, but there's not much there about parallelism. The
  only mention of "iterator" in here is preceded by the word "serial", which
  is the opposite of "parallel". The only real output seems to be the
  allocation (and subsequent deallocation) of locales, which are Chapel's
  generalization of "places where computation can occur".

  What might be causing this? We don't have to dig too deep; the
  [documentation for `channel.lines`](https://chapel-lang.org/docs/modules/standard/IO.html#IO.channel.lines),
  which I also linked earlier, notes:

  > Only serial iteration is supported.

  Since our other iterators build on top of `lines()` by transforming the things
  it yields, our iterators become serial, too. There's no way to distribute
  a serial iterator - it can _only_ be read one item at a time, without
  the ability to look ahead (and thus give other threads something to work on).

  Not all is lost, though. Plain old [arrays](https://chapel-lang.org/docs/language/spec/arrays.html)
  support parallel iteration. We can easily read an iterator into an array, just
  by assigning it to a variable.

  ```Chapel
  var elfArray = elves();
  writeln(max reduce elfArray);
  ```

  This time, I get a lot more output:

  {{< details summary="(program output using an intermediate array...)" >}}
  ```
  *** DR alloc locale 0
  *** DR calling postalloc locale 0
  *** DR alloc locale 1
  *** DR calling postalloc locale 1
  *** DR alloc locale 1
  *** DR calling postalloc locale 1
  *** In defRectArr simple-dd standalone iterator
  *** In domain standalone code:
      numTasks=10 (false), minIndicesPerTask=1
      numChunks=10 parDim=0 ranges(0).size=143999
  ### numTasksPerLoc = 10
  ### ignoreRunning = false
  ### minIndicesPerTask = 1
  ### numChunks = 10 (parDim = 0)
  ### nranges = (0..143998)
  *** DI: ranges = (0..143998)
  *** DI[0]: block = (0..14399)
  *** DI[1]: block = (14400..28799)
  *** DI[5]: block = (72000..86399)
  *** DI[6]: block = (86400..100799)
  *** DI[8]: block = (115200..129599)
  *** DI[2]: block = (28800..43199)
  *** DI[3]: block = (43200..57599)
  *** DI[4]: block = (57600..71999)
  *** DI[7]: block = (100800..115199)
  *** DI[9]: block = (129600..143998)
  <puzzle answer>
  *** DR calling dealloc int(64)
  *** In defRectArr simple-dd serial iterator
  *** DR calling dealloc locale
  *** In defRectArr simple-dd serial iterator
  *** DR calling dealloc locale
  *** DR calling dealloc locale
  ```
  {{< /details >}}

  Even more output! There are a few signs of parallelism in there. For instance,
  the following line indicates that our workload is being split into chunks.
  ```
  ### numChunks = 10 (parDim = 0)
  ```
  The reason to split data into chunks is to that each independent task can
  have its own piece of the workload. I'm further reassured by the actual
  number of chunks. It so happens that my computer has ten logical cores.
  A Python script can be used to check:

  ```Python
  import multiprocessing as mp;
  print(mp.cpu_count())
  ```

  On my machine, this prints `10`. So Chapel is automatically distributing
  the work across all my cores! We did have to tweak the code a little
  bit (specifically, we needed to make sure that what we're giving to the
  reduction can be traversed in parallel). However, it's still very simple.
*/

/* {{< skip >}} */

/*
  For part 2, I'm going to do something a bit more unusual. Chapel has support
  for reduction expressions, which can even be run in parallel over many
  threads. I'll implement picking the top `k` elements as a
  custom reduction. If I implement all the methods on this reduction
  class, I'll be able to automatically make my code run on multuple threads!
*/
class MaxK : ReduceScanOp {
  param k: int;
  /* Reductions have an element type, the thing-that's-being-processed.
     This element type is left generic to support reductions over different
     types of things. */
  type eltType;
  /* The value our reduction is building up is a top-`k` list of the largest
     numbers. This top-`k` list is represented by a `k`-element tuple
     of `eltType`, written as `k*eltType`. */
  var value: k*eltType;

  /* Reductions need an identity element. This is an element that doesn't
     do anything when processed. For instance, for summing, the identity
     element is zero (adding zero to a sum doesn't change the sum). For
     finding a product, the identity element is one (multiplying by one
     leaves the product intact). When finding the _largest_ `k` numbers
     in a list, the identity element is `k` [infinums](https://en.wikipedia.org/wiki/Infimum_and_supremum)
     of that list. We'll assume that the default value of the `eltType`
     is its infinum, which means default-initializing a tuple of `k`
     `eltTypes` will give us such a `k`-infinum tuple.
   */
  proc identity {
    var val: value.type;
    return val;
  }
  /*
   Next are accumulation functions. These describe how to combine partial
   results from substs of the list of numbers, or how to update the top
   `k` given a new number. We only need to _really_ implement one version of
   these functions - one that combines two k-tuples. The rest can be defined
   in terms of that function.
  */
  proc accumulate(x: eltType) { accumulateOntoState(value, x); }
  proc accumulateOntoState(ref state: k*eltType, x: eltType) { accumulateOntoState(state, (0, 0, x)); }
  proc accumulate(x: k*eltType) { accumulateOntoState(value, x); }

  /* The accumulation function uses a standard algorithm for merging two sorted
     lists. */
  proc accumulateOntoState(ref state: k*eltType, x: k*eltType) {
    var result: state.type;
    var ptr1, ptr2: int = k-1;
    for param idx in (0..<k by -1) {
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
  proc combine(other: MaxK(k, eltType)) {
    accumulate(other.value);
  }

  /* The Chapel reduction feature requires a couple of other methods,
     which we implement below. */
  proc clone() return new unmanaged MaxK(k=k, eltType=eltType);
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
var elfArray = elves();
if part == 1 {
  /* For part 1, the code remains the same, since we're still just finding
     the one maximum number. */
  writeln(max reduce elfArray);
} else if part == 2 {
  var reducer = new unmanaged MaxK(k=3, eltType=int);
  var topThree = (0,0,0);
  forall elf in elfArray with (reducer reduce topThree) {
    topThree reduce= elf;
  }

  writeln(+ reduce topThree);
}

/* {{< /skip >}} */
