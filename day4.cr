require "advent"

struct Range(B, E)
  def contains?(other)
    other.begin >= self.begin && other.end <= self.end
  end

  def overlaps?(other)
    these = self.to_a
    others = other.to_a
    these.any? { |i| others.includes? i }
  end
end

INPUT = input(2022, 4).lines.map do |line|
  first, second = line.split(",").map do |str|
    left, right = str.split("-").map &.to_i64
    left..right
  end
  {first, second}
end

def part1(input)
  input.count do |pair|
    l, r = pair
    l.contains?(r) || r.contains?(l)
  end
end

def part2(input)
  input.count do |pair|
    l, r = pair
    l.overlaps?(r)
  end
end

puts part1(INPUT.clone)
puts part2(INPUT.clone)
