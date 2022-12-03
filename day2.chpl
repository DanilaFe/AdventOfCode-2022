use Map;
use IO;

var winsOne = new map(string, int);
winsOne["AX"] = 3 + 1;
winsOne["AY"] = 6 + 2;
winsOne["AZ"] = 0 + 3;
winsOne["BX"] = 0 + 1;
winsOne["BY"] = 3 + 2;
winsOne["BZ"] = 6 + 3;
winsOne["CX"] = 6 + 1;
winsOne["CY"] = 0 + 2;
winsOne["CZ"] = 3 + 3;

var winsTwo = new map(string, int);
winsTwo["AX"] = 0 + 3;
winsTwo["AY"] = 3 + 1;
winsTwo["AZ"] = 6 + 2;
winsTwo["BX"] = 0 + 1;
winsTwo["BY"] = 3 + 2;
winsTwo["BZ"] = 6 + 3;
winsTwo["CX"] = 0 + 2;
winsTwo["CY"] = 3 + 3;
winsTwo["CZ"] = 6 + 1;

iter scores(map) {
  for line in stdin.lines() {
    yield map[line.strip().replace(" ", "")];
  }
}

config const part = 1;
writeln(+ reduce (scores(if part == 1 then winsOne else winsTwo)));
