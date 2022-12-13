require "advent"
INPUT = input(2022, 13).lines

class Tree
  property value : Int32?
  property values : Array(Tree)?

  def initialize(@value, @values)
  end

  def to_s(io)
    if mine = value
      io << "value: " << mine
    elsif mine = values
      io << "values: "
      mine.each do |v|
        io << "("
        v.to_s io
        io << ")"
      end
    end
  end

  def compare(other : Tree)
    if mine = value
      if yours = other.value
        return (mine - yours).sign
      end
    end

    if mine = values
      if yours = other.values
        mine.size.times do |i|
          return 1 unless i < yours.size # Shorter list smaller
          comp = mine[i].compare yours[i]
          return comp if comp != 0
        end
        return mine.size == yours.size ? 0 : -1 # Shorter list smaller
      end
    end

    if mine = value
      return Tree.new(nil, [self]).compare(other)
    elsif yours = other.value
      return compare(Tree.new(nil, [other]))
    end
    return 0
  end
end

def tree(i)
  Tree.new(i, nil)
end

def list(is : Array(Int32))
  Tree.new(nil, is.map { |it| tree(it) })
end

def list(is : Array(Tree))
  Tree.new(nil, is)
end

def parse(string)
  stack = [[] of Tree]
  current = nil
  string.as(String).each_char do |c|
    if c == '['
      stack << [] of Tree
    elsif c.alphanumeric?
      if current.nil?
        current = c.to_i32
      else
        current = current * 10 + c.to_i32
      end
    elsif c == ','
      if num = current
        stack.last << tree(num)
        current = nil
      end
    elsif c == ']'
      if num = current
        stack.last << tree(num)
        current = nil
      end
      new_tree = Tree.new(nil, stack.pop)
      stack.last << new_tree
    end
  end
  return stack[0][0]
end

puts parse("[[10,1,2],[],[]]")
total = 0
INPUT.in_groups_of(3).each_with_index do |group, i|
  t1 = parse(group[0])
  t2 = parse(group[1])
  cmp = t1.compare t2
  total += (i+1) if cmp != 1
end
puts total

trees = INPUT.reject { |it| it.empty? }.map { |it| parse(it) }
d1 = parse("[[2]]")
d2 = parse("[[6]]")
trees << d1
trees << d2
trees.sort! do |l, r|
  l.compare r
end
puts (trees.index!(d1)+1)*(trees.index!(d2)+1)
