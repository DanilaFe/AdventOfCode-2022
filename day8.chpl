use IO;

// It's easiest to just yield all numbers as a list, then reshape that list
// into a square given `rowSize` information.
iter allNumbers(ref rowSize: int) {
  for line in stdin.lines() {
    const trimmedLine = line.strip();
    rowSize = trimmedLine.size;

    for num in trimmedLine {
      yield num : int;
    }
  }
}

// Time to do that reshaping!
var rowSize = 0;
var allNums = allNumbers(rowSize);
var shapedNums = reshape(allNums, { 1..allNums.size / rowSize, 1..rowSize });

// In this problem, we're considering the view from each direction at each
// tree. Define a helper iterator to return an array slice representing trees
// in that direction, as well as the "by" step indicating which direction
// the path should be walked in.
iter eachDirection((x,y)) {
  yield (shapedNums[..<x,y], -1);
  yield (shapedNums[x+1..,y], 1);
  yield (shapedNums[x,..<y], -1);
  yield (shapedNums[x,y+1..], 1);
}

// All that's left is to write special-case behavior for each part.

// In part 1, we check if a tree is _never_ blocked along a direction; this can be
// accomplished by checking whether or not all trees are less tall than the current tree.
proc int.visibleAlong((trees, step)) {
  return max reduce trees < this;
}

// In part 2, we count the number of trees until a taller tree is encountered.
// Here we iterate serially, and use our `step` parameter.
proc int.scoreAlong((trees, step)) {
  var count = 0;
  for idx in trees.domain by step {
    count += 1;
    if trees[idx] >= this then break;
  }
  return count;
}

// Finally, we iterate (in parallel) over each tree, and tally up if it's
// visible, as well as compute and note its score.
var visible = 0;
var bestScore = 0;
forall coord in shapedNums.domain with (+ reduce visible, max reduce bestScore) {
  const tree = shapedNums[coord];
  visible += || reduce tree.visibleAlong(eachDirection(coord));
  bestScore reduce= * reduce tree.scoreAlong(eachDirection(coord));
}
writeln(visible);
writeln(bestScore);
