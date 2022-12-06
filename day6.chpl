use IO;

config const numChars = 4;

var theBytes: bytes;
stdin.read(theBytes);

var indices: [0..<26] int = -numChars;

for (char, idx) in zip(theBytes.these() - b"a"[0], 0..) do {
  indices[char] = idx;

  if + reduce (indices > idx - numChars) == numChars {
    writeln(idx + 1);
    break;
  }
}
