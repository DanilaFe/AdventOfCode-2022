require "advent"
INPUT = input(2022, 8).lines.map(&.chars.map(&.to_i32)) 

def visible_in_row(arr, idx)
  (arr[..idx-1].max < arr[idx]) || (arr[idx+1..].max < arr[idx])
end

def score(arr, x, y, dx, dy)
  tree = arr[x][y]
  x += dx
  y += dy
  count = 0
  while x >= 0 && x < arr.size && y >= 0 && y < arr[x].size && arr[x][y] < tree
    count += 1
    x += dx
    y += dy
  end
  count += 1 if (x >= 0 && x < arr.size && y >= 0 && y < arr[x].size)
  puts ({dx, dy, count}).to_s
  count
end

def part1(input)
  input_t = input.transpose
  count = 0
  count += input.size * 2
  count += (input[0].size - 2) * 2
  (input.size - 2).times do |x|
    x += 1
    (input[x].size - 2).times do |y|
      y += 1
      tree = input[x][y]
      if visible_in_row(input[x], y) || visible_in_row(input_t[y], x)
        puts ({x, y, tree}).to_s
        count += 1 
      end
    end
  end
  count
end

def part2(input)
  best = 0
  (input.size - 0).times do |x|
    (input[x].size - 0).times do |y|
      tree_score = score(input, x, y, 1, 0) * score(input, x, y, -1, 0) * score(input, x, y, 0, 1) * score(input, x, y, 0, -1)
      puts ({x, y, input[x][y], tree_score}).to_s
      if tree_score > best
        best = tree_score 
      end
      puts "--"
    end
  end
  best
end

puts part1(INPUT.clone)
puts part2(INPUT.clone)
