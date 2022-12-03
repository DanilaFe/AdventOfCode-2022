require "advent"

INPUT = input(2022, 2).lines.map do |l|
  a, b =  l.split(" ")
  {a, b}
end

WINS1 = {
  "AX" => 3 + 1,
  "AY" => 6 + 2,
  "AZ" => 0 + 3,

  "BX" => 0 + 1,
  "BY" => 3 + 2,
  "BZ" => 6 + 3,

  "CX" => 6 + 1,
  "CY" => 0 + 2,
  "CZ" => 3 + 3,
}

WINS2 = {
  "AX" => 0+3,
  "AY" => 3+1,
  "AZ" => 6+2,

  "BX" => 0+1,
  "BY" => 3+2,
  "BZ" => 6+3,

  "CX" => 0+2,
  "CY" => 3+3,
  "CZ" => 6+1,
}

def part1(input)
  input.sum do |x|
    a,b = x
    WINS1[a+b]
  end
end

def part2(input)
  input.sum do |x|
    a,b = x
    WINS2[a+b]
  end
end

puts part1(INPUT)
puts part2(INPUT)
