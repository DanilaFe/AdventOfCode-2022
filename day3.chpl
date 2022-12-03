use Set;
use IO;

const lowercase: [1..26] string = "abcdefghijklmnopqrstuvwxyz".these();
const uppercase: [27..52] string = "abcdefghijklmnopqrstuvwxyz".toUpper().these();

proc letterScore(letter: string): int {
  var (isLower, score1) = lowercase.find(letter);
  if isLower then return score1;
  var (isUpper, score2) = uppercase.find(letter);
  if isUpper then return score2;
  halt("Should not happen");
}

proc charSet(str: string): set(string) {
  return new set(string, str);
}

proc groupScore(group): int {
  var inAll = new set(string, lowercase) | new set(string, uppercase);
  for chars in charSet(group) {
    inAll &= chars;
  }
  return + reduce letterScore(inAll.these());
}

iter inputLines() {
  for line in stdin.lines() do yield line.strip();
}

iter inputLineHalves() {
  for line in inputLines() {
    yield line[..<line.size/2];
    yield line[line.size/2..];
  }
}

proc solveByReshaping(it, size) {
  const array = it;
  const shaped = reshape(array, {1..(array.size / size), 1..size});
  var total = 0;
  forall i in shaped.dim(0) with (+ reduce total) {
    total reduce= groupScore(shaped[i,..]);
  }
  return total;
}

config const part = 1;

if part == 1 {
  writeln(solveByReshaping(inputLineHalves(), 2));
} else if part == 2 {
  writeln(solveByReshaping(inputLines(), 3));
}
