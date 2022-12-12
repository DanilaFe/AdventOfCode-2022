require "advent"
INPUT = input(2022, 12).lines.map(&.chars) 
EDGES = {} of Tuple(Int32,Int32) => Array(Tuple(Int32, Int32))

def add_at(pos, c, x, y)
  return unless y >= 0 && y < INPUT.size
  return unless x >= 0 && x < INPUT[0].size

  o = INPUT[y][x]
  o = 'a' if o == 'S'
  o = 'z' if o == 'E'

  return if (c.ord-o.ord) > 1
  EDGES[pos] << ({x,y});
end

def add_nearby(x, y)
  c = INPUT[y][x]
  c = 'a' if c == 'S'
  c = 'z' if c == 'E'

  if !EDGES[{x,y}]?
    EDGES[{x,y}] = [] of Tuple(Int32,Int32)
  end
  add_at({x,y}, c, x+1, y)
  add_at({x,y}, c, x-1, y)
  add_at({x,y}, c, x, y+1)
  add_at({x,y}, c, x, y-1)
end

from = {0,0}
to = {100,100}
INPUT.each_with_index do |row, y|
  row.each_with_index do |c, x|
    pos = {x, y}
    add_nearby(x, y)
    from = pos if c == 'E'
  end
end

costs = {from => 0}
mins = {} of Tuple(Int32, Int32) => Int32
visited = Set(Tuple(Int32, Int32)).new

while !costs.empty?
  k, v = costs.min_by do |k,v|
    v
  end

  if k == to
    puts "Found! #{v}"
    break
  end

  costs.delete k
  mins[k] = v
  visited << k
  INPUT[k[1]][k[0]] = INPUT[k[1]][k[0]].upcase
  puts k

  EDGES[k].each do |edge|
    next if visited.includes? edge
    if old = costs[edge]?
      costs[edge] = v+1 if old > v+1
    else
      costs[edge] = v+1
    end
  end
end

lengths = [] of Int32
puts mins
INPUT.each_with_index do |line, y|
  line.each_with_index do |c, x|
    next unless c == 'A'
    if amin = mins[{x,y}]?
      lengths << amin 
    end
    print c
  end
  puts
end
puts lengths.min
