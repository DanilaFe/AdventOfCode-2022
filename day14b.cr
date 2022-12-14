require "advent"
INPUT = input(2022, 14).lines

occupied = {} of Tuple(Int32, Int32) => Bool
INPUT.each do |line|
  points = line.split("->").map &.split(",").map(&.to_i32)
  points.each_cons_pair do |p1,p2|
    x1, y1 = p1
    x2, y2 = p2
    dx = (x2-x1).sign
    dy = (y2-y1).sign
    ((x2-x1).abs+1).times do |nx|
      ((y2-y1).abs+1).times do |ny|
        pos = {x1 + nx*dx, y1 + ny*dy}
        occupied[pos] = true
      end
    end
  end
end

max_height = occupied.max_of do |k,v|
  x, y = k
  y
end

puts "Max height: #{max_height}"

def each_place(pos, &block)
  x, y = pos
  yield ({x+1, y+1})
  yield ({x-1, y+1})
  yield ({x, y+1})
end

puts occupied

count = 0
until occupied[{500,0}]?
  pos = {500, 0}
  moved = false
  loop do
    moved = false
    each_place(pos) do |check|
      next if occupied[check]? || check[1] == max_height+2
      pos = check
      moved = true
    end
    break unless moved
  end
  occupied[pos] = true
  count += 1
end

puts count
