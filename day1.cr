require "advent"
INPUT = input(2022, 1).lines#.lines.map(&.to_i32)


def part1(input)
  list = [] of Array(String)
  current = [] of String
  input.each do |line|
    if line.empty?
      list << current
      current = [] of String
    else
      current << line
    end
  end
  if !current.empty?
    list << current
  end

  list.max_of do |list|
    list.map(&.to_i32).sum
  end
end

def part2(input)
  list = [] of Array(String)
  current = [] of String
  input.each do |line|
    if line.empty?
      list << current
      current = [] of String
    else
      current << line
    end
  end
  if !current.empty?
    list << current
  end

  data = list.map(&.map(&.to_i32).sum)
  data.sort!
  data[-1] + data[-2] + data[-3]
end

puts part1(INPUT.clone)
puts part2(INPUT.clone)
