require "advent"
INPUT = input(2022, 6).lines[0].chars

def part1(input)
  offset = 0
  loop do
    chars = input[offset..offset+3]
    return offset + 4 if chars.uniq.size == 4
    offset += 1
  end
end

def part2(input)
  offset = 0
  loop do
    chars = input[offset..offset+13]
    return offset + 14 if chars.uniq.size == 14
    offset += 1
  end
end

puts part1(INPUT.clone)
puts part2(INPUT.clone)
