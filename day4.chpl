use IO;

iter pairs() {
  var low1, low2, high1, high2 : int;
  while readf("%i-%i,%i-%i", low1, high1, low2, high2) do
    yield (low1..high1, low2..high2);
}

proc anyContains((r1, r2): 2*range) { return r1.contains(r2) || r2.contains(r1); }
proc overlap((r1, r2): 2*range) { return !r1[r2].isEmpty(); }

var thePairs = pairs();
writeln(+ reduce anyContains(thePairs));
writeln(+ reduce overlap(thePairs));
