require "advent"

INPUT = input(2022, 9).lines.map do |line|
  dir, n = line.split(" ");
  {dir, n.to_i64}
end


positions = Set(Tuple(Int32, Int32)).new

diff = { "L" => {-1, 0}, "R" => {1, 0}, "U" => {0, 1}, "D" => {0, -1} }

def move(h, d)
  {h[0] + d[0], h[1] + d[1]}
end

def follow(h, t)
  hx, hy = h
  tx, ty = t
  dx = hx-tx
  dy = hy-ty

  if dx.abs > 1 && dy.abs == 0
    tx += dx.sign
  elsif dy.abs > 1 && dx.abs == 0
    ty += dy.sign
  elsif dx.abs + dy.abs > 2
    tx += dx.sign
    ty += dy.sign
  end

  h = {hx, hy}
  t = {tx, ty}
  return {h, t}
end

def simulate(knots, d)
  knots[0] = move(knots[0], d)
  (knots.size-1).times do |i|
    knots[i], knots[i+1] = follow(knots[i], knots[i+1])
  end
end


knots = [{0, 0}] * 10
INPUT.each do |cmd|
  dir, n = cmd
  d = diff[dir]

  n.times do
    simulate(knots, d)
    positions << knots.last
  end
end

puts positions.size
