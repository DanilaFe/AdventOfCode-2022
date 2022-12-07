use IO, Map, List;

class TreeNode {
  var name: string;
  var parent: borrowed TreeNode?;

  var files = new map(string, int);
  var dirs = new list(owned TreeNode);

  var size = -1;

  proc init(name: string, parent: borrowed TreeNode?) {
    this.name = name;
    this.parent = parent;
  }

  /*

  ```Chapel
  iter these(param tag: iterKind): (string, int) where tag == iterKind.standalone {
    var size = + reduce files.values();
    coforall dir in dirs with (+ reduce size) {
      // Yield directory sizes from the dir.
      forall subSize in dir do yield subSize;
      // Count its size for our size.
      size += dir.size;
    }
    yield (name, size);
    this.size = size;
  }
  ```

  */

  iter these(): (string, int) {
    var size = + reduce files.values();
    for dir in dirs {
      // Yield directory sizes from the dir.
      for subSize in dir.these() do yield subSize;
      // Count its size for our size.
      size += dir.size;
    }
    yield (name, size);
    this.size = size;
  }
}

var rootFolder: owned TreeNode = new owned TreeNode("", nil);
var currentFolder: borrowed TreeNode = rootFolder.borrow();

for line in stdin.lines() {
  const strippedLine = line.strip();
  if strippedLine == "$ cd .." {
    if const parent = currentFolder.parent then
      currentFolder = parent;
  } else if strippedLine.startsWith("$ cd ") {
    const dirName = strippedLine["$ cd ".size..];
    var newFolder = new owned TreeNode(dirName, currentFolder);
    currentFolder.dirs.append(newFolder);
    currentFolder = currentFolder.dirs.last().borrow();
  } else if !strippedLine.startsWith("$ ls") {
    const (sizeOrDir, _, name) = strippedLine.partition(" ");
    if sizeOrDir == "dir" {
      // Ignore directories, we'll CD into them.
    } else {
      currentFolder.files[name] = sizeOrDir : int;
    }
  }
}

writeln(+ reduce [(_, size) in rootFolder] if size < 100000 then size);

const toDelete = rootFolder.size - 40000000;
writeln(min reduce [(_, size) in rootFolder] if size >= toDelete then size);
