require "advent"

def letter_score(letter : Char)
  if letter.uppercase?
    letter.ord - 'A'.ord + 1 + 26
  else
    letter.ord - 'a'.ord + 1
  end
end

INPUT = input(2022, 3).lines

def part1(input)
  input = input.map do |line|
    first = line[0, line.size//2]
    second = line[line.size//2, line.size//2]
    {first.chars.to_set, second.chars.to_set}
  end
  input.sum do |a,b|
    puts (a & b)
    (a & b).to_a.map do |l|
      puts letter_score(l)
      letter_score(l)
    end.sum
  end
end

def part2(input)
  input
    .map(&.chars.to_set)
    .in_groups_of(3, Set(Char).new)
    .map(&.reduce { |l,r| l & r  }.sum { |l| letter_score l })
    .sum
end

puts part1(INPUT.clone)
puts part2(INPUT.clone)
