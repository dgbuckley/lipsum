# lipsum

A utility to mash up lines of text. The purpose of this project is to generate
random lines of real text to be used for typing practice.

To better practice actual code writing I created this to generate random input
for [keybr.com](https://keybr.com) from existing code. The resulting text allows
keybr.com to then test me using the full suit of characters I interact with when
programming.

# Usage

`lipsum [-h] [-n <NUM>] <MATCH> <DIRECTORY>...`

```bash
  -h            Display this help message.
  -n <NUM>      Number of lines to ouput.
```

# Examples

Here are some output examples:

## Zig

- Source: https://github.com/ziglang/zig
- Generated with: `lipsum -n 10 '.*.zig' | tr -s ' '`

```zig
 \\test "aoeu" {
 try testCanonical(
 if (std.mem.indexOfScalarPos(u8, slice[0..std.math.min(index + 9, slice.len)], index + 3, '}')) |index_end| {
 rparen: TokenIndex,
 const arrow = try p.expectToken(.EqualAngleBracketRight);
 tree.tokensOnSameLine(expr.lastToken(), maybe_comment))
 };
 },
 '>' => {
 .op_token = asterisk,

```
