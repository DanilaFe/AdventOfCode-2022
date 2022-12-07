require "advent"
INPUT = input(2022, 7).lines[1..]

class DirTree
  property name : String
  property files : Hash(String, Int64)
  property subDirs : Array(DirTree)
  property parent : DirTree?

  def initialize(@name, @parent)
    @files = {} of String => Int64
    @subDirs= [] of DirTree
    @parent.try &.subDirs.<<(self)
  end

  def sum_yielding(&block : Int32 ->): Int32
    size = 0
    size += @subDirs.sum do |x|
      x.sum_yielding(&block)
    end
    size += @files.sum { |k,v| v }
    yield size
    return size
  end
end

dir = DirTree.new("", nil)

INPUT.each do |line|
  if line =~ /\$ cd (.+)$/
    if $1 == ".."
      dir = dir.parent.not_nil!
    else
      dir = DirTree.new($1, dir)
    end
  elsif line == "$ ls"
  else
    x, y = line.split(" ")
    if x == "dir"
    else
      dir.files[y] = x.to_i64
    end
  end
end

while par = dir.parent
  dir = par
end

total = 0
outer_size = dir.sum_yielding do |i|
  total += i if i <= 100000
end
puts total

puts "Used: #{outer_size}"
puts "Unused: #{70000000 -  outer_size}"
to_delete = 30000000 - (70000000 - outer_size)
puts "To delete: #{to_delete}"
big_enough = [] of Int32
outer_size = dir.sum_yielding do |i|
  big_enough << i if i >= to_delete
end
puts big_enough.min
