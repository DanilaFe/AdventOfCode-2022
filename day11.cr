require "advent"
require "big"

class Monkey
  property items : Array(Int64)
  property op : String
  property divBy : Int64
  property ifTrue : Int64
  property ifFalse : Int64

  def initialize(@items, @op, @divBy, @ifTrue, @ifFalse)
  end
end

INSTS = {
  "*" => ->(x: Int64, y: Int64) { x * y },
  "+" => ->(x: Int64, y: Int64) { x + y }
}

def execute(inst, old, mod)
  inst = inst.gsub("old", old.to_s);
  l, op, r = inst.split(" ")
  l = l.to_i64 % mod
  r = r.to_i64 % mod
  INSTS[op].call(l,r)
end

monkeys = [] of Monkey
input(2022, 11).split("\n\n").each do |it|
  it = it.lines
  items = it[1].split(": ")[1].split(", ").map(&.to_i64).reverse
  op = it[2].split("Operation: new = ")[1]
  divBy = it[3].split("Test: divisible by ")[1].to_i64
  ifTrue = it[4].split("  If true: throw to monkey ")[1].to_i64
  ifFalse = it[5].split("  If false: throw to monkey ")[1].to_i64
  monkeys << Monkey.new(items, op, divBy, ifTrue, ifFalse)
end

counts = [0] * monkeys.size
modulus = monkeys.map(&.divBy).product
10000.times do
  monkeys.each_with_index do |m, i|
    while !m.items.empty?
      counts[i] += 1
      item = m.items.pop
      item = execute(m.op, item, modulus)
      item = item % modulus
      if item % m.divBy == 0
        monkeys[m.ifTrue].items.insert(0, item)
      else
        monkeys[m.ifFalse].items.insert(0, item)
      end
    end
  end
end

counts.sort!
puts counts[-1].to_big_i * counts[-2].to_big_i
