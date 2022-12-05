require "advent"
boxes, instructions = input(2022, 5).split("\n\n")
boxes = parse_boxes_lines(boxes.lines);
instrs = parse_instrs(instructions.lines);

def parse_instr(str)
  _, n, _, f, _, t = str.split(" ")
  { n.to_i64, f.to_i64, t.to_i64 }
end

def parse_instrs(lines)
  lines.map { |l| parse_instr(l) }
end

def parse_boxes_line(str)
  str += " "
  str.chars.in_groups_of(4).map do |group|
    group[1]
  end
end

def parse_boxes_lines(lines)
  lines.pop
  lines = lines.map { |l| parse_boxes_line(l) }
  lines = lines.transpose
  lines.each do |line|
    line.reject!(&.==(' ')).reverse!
  end
  lines
end

def move(from, to, n)
  # n.times do
  #   to << from.pop
  # end
  from.pop(n).each do |x|
    next unless x 
    to.push(x)
  end
end

instrs.each do |instr|
  n, f, t = instr
  move(boxes[f-1], boxes[t-1], n)
end

puts boxes.map(&.last).join("")
