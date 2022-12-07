// Advent of Code 2022, Day 7: Traversing Directories
// authors: ["Daniel Fedorin"]
// summary: "A solution to day seven of AoC 2022, introducing classes and memory management."
// tags: ["Advent of Code 2022"]
// date: 2022-12-07

/*
  Welcome to day 7 of Chapel's Advent of Code 2022 series. We're over halway
  through the twelve days of Chapel AoC! In case you haven't been following
  the series, check out the introductory [Advent of Code 2022: Twelve
  Days of Chapel](../aoc2022-day00-intro/) article for more context.
 */

/*
  ### The Task at Hand and My Approach

  In today's puzzle, we are given a list of terminal-like commands (
  [`ls`](https://man7.org/linux/man-pages/man1/ls.1.html) and [`cd`](https://man7.org/linux/man-pages/man1/cd.1p.html)
  ), as well as output corresponding to running these commands. The commands
  explore a fictional file system, which can have files (objects with size)
  as well as directories that group files and other (sub-)directories. The
  problem then asks to compute the sizes of each folder, and to total up the
  sizes of all folders that are smaller than a particular threshold.

  The tree-like nature of the file system does not make it amenable to
  representations based on arrays, lists, and maps alone. The trouble with
  these data types is that they're flat. Our input could -- and will -- have arbitrary
  levels of nested directories. However, arrays, lists, and maps cannot have
  such arbitrary nesting -- we'd need something like a list of lists of lists...
  We could, of course, use the `map` and `list` data types to represent the
  file system with some sort of [adjacency list](https://en.wikipedia.org/wiki/Adjacency_list).
  However, such an implementation would be somewhat clunky and hard to use.

  Instead, we'll use a different tool from the repertoire of Chapel language
  features, one we haven't seen so far: classes. Much like in most languages,
  classes are a way to group together related pieces of data. up until now,
  we've used tuples for this purpose.

*/

use IO, Map, List;

class TreeNode {
  var name: string;

  var files = new map(string, int);
  var dirs = new list(owned TreeNode);

  proc init(name: string) {
    this.name = name;
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

  iter dirSizes(ref parentSize = 0): (string, int) {
    var size = + reduce files.values();
    for dir in dirs {
      // Yield directory sizes from the dir.
      for subSize in dir.dirSizes(size) do yield subSize;
    }
    yield (name, size);
    parentSize += size;
  }

  proc type fromInput(name: string, readFrom): owned TreeNode {
    var line: string;
    var newDir = new TreeNode(name);

    while readFrom.readLine(line, stripNewline = true) {
      if line == "$ cd .." {
        break;
      } else if line.startsWith("$ cd ") {
        const dirName = line["$ cd ".size..];
        newDir.dirs.append(TreeNode.fromInput(dirName, readFrom));
      } else if !line.startsWith("$ ls") {
        const (sizeOrDir, _, name) = line.partition(" ");
        if sizeOrDir == "dir" {
          // Ignore directories, we'll `cd` into them.
        } else {
          newDir.files[name] = sizeOrDir : int;
        }
      }
    }
    return newDir;
  }
}

var rootFolder = TreeNode.fromInput("", stdin);

var rootSize = 0;
writeln(+ reduce [(_, size) in rootFolder.dirSizes(rootSize)] if size < 100000 then size);

const toDelete = rootSize - 40000000;
writeln(min reduce [(_, size) in rootFolder.dirSizes()] if size >= toDelete then size);
