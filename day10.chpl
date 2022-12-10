use IO, Map;

iter ops() {
  yield 1; // Initial state
  for line in stdin.lines().strip() {
    select line[0..3] {
      when "noop" do yield 0;
      when "addx" {
        yield 0;
        yield line[5..] : int;
      }
    }
  }
}

const deltas = ops();
const states = + scan deltas;
const indices = 20..220 by 40;
writeln(+ reduce (states[indices-1] * indices));

const pixels = [(x, pc) in zip(states[0..<240], 0..)]
  if abs((pc % 40) - x) <= 1 then "#" else " ";
writeln(reshape(pixels, {1..6, 1..40}));
