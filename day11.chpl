use IO, List;

var modulus = 1;

record DivByThree {
  var underlying: int;
  operator +(lhs: DivByThree, rhs: DivByThree) {
    return new DivByThree((lhs.underlying + rhs.underlying) / 3);
  }
  operator *(lhs: DivByThree, rhs: DivByThree) {
    return new DivByThree((lhs.underlying * rhs.underlying) / 3);
  }
  proc divBy(x: int) return underlying % x == 0;
}

record Modulo {
  var underlying: int;

  operator +(lhs: Modulo, rhs: Modulo) {
    return new Modulo((lhs.underlying + rhs.underlying) % modulus);
  }
  operator *(lhs: Modulo, rhs: Modulo) {
    return new Modulo((lhs.underlying * rhs.underlying) % modulus);
  }
  proc divBy(x: int) return underlying % x == 0;
}

config type numtype = DivByThree;
config const steps = 20;

class Op {
  proc apply(x: ?t) return x;
}

class SquareOp : Op {
  override proc apply(x) return x * x;
}

class AddOp : Op {
  var toAdd;
  override proc apply(x) return x + toAdd;
}

class MulOp : Op {
  var toMul;
  override proc apply(x) return x * toMul;
}

proc parse(op: string): owned Op {
  if op == "old * old" then return new SquareOp();
  if op.startsWith("old + ") then return new AddOp(new numtype(op[6..] : int));
  return new MulOp(new numtype(op[6..] : int));
}

record Monkey {
  var op : owned Op;
  var divBy, ifTrue, ifFalse : int;
  var items: list(numtype);
  var count: int = 0;

  iter tossItems() {
    while !items.isEmpty() {
      var item = items.pop(0);
      var changed = op.apply(item);
      var nextIdx = if changed.divBy(divBy) then ifTrue else ifFalse;
      count += 1;
      yield (changed, nextIdx);
    }
  }
}

var monkeys = new list(Monkey);
var line: string;
while readLine(line) {
  proc toNum(x: string) return new numtype(x : int);
  readLine(line, stripNewline=true);
  var items = new list(toNum(line["  Starting items: ".size..].split(", ")));
  readLine(line, stripNewline=true);
  var op = parse(line["  Operation: new = ".size..]);
  var divBy, ifTrue, ifFalse: int;
  readf("  Test: divisible by %i\n", divBy);
  readf("    If true: throw to monkey %i\n", ifTrue);
  readf("    If false: throw to monkey %i\n", ifFalse);
  monkeys.append(new Monkey(op, divBy, ifTrue, ifFalse, items));
  modulus *= divBy;
  if (!readln()) then break;
}

for 1..steps {
  for monkey in monkeys {
    for (item, nextIdx) in monkey.tossItems() {
      monkeys[nextIdx].items.append(item);
    }
  }
}
writeln(monkeys.these().count);
