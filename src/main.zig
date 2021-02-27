const std = @import("std");
const rand = std.rand;
const mem = std.mem;
const testing = std.testing;
const os = std.os;
const heap = std.heap;
const fs = std.fs;

const ArrayListUnmanaged = std.ArrayListUnmanaged;

const clap = @import("clap");
const Regex = @import("regex").Regex;

pub fn main() anyerror!void {
    var ally = heap.GeneralPurposeAllocator(.{}){};
    defer _ = ally.deinit();
    var arena = heap.ArenaAllocator.init(&ally.allocator);
    defer arena.deinit();

    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h            Display this help message.") catch unreachable,
        clap.parseParam("-n <NUM>      Number of lines to ouput.") catch unreachable,
        clap.parseParam("<MATCH> <FILE/DIRECTORY>...") catch unreachable,
    };

    var diag: clap.Diagnostic = undefined;
    var args = clap.parse(clap.Help, &params, &arena.allocator, &diag) catch |err| {
        try diag.report(std.io.getStdErr().writer(), err);
        os.exit(1);
    };

    if (args.flag("-h")) try clap.usage(std.io.getStdErr().writer(), &params);

    var list = ArrayListUnmanaged([]const u8){};
    if (args.positionals().len < 1)
        try clap.usage(std.io.getStdErr().writer(), &params)
    else {
        var reg = try Regex.compile(&arena.allocator, args.positionals()[0]);

        if (args.positionals().len == 1) {
            var dir = try fs.cwd().openDir(".", .{ .iterate = true });
            try walk(dir, &arena.allocator, &list, &reg);
        } else {
            for (args.positionals()[1..]) |dir_name| {
                var dir = try fs.cwd().openDir(dir_name, .{ .iterate = true });
                try walk(dir, &arena.allocator, &list, &reg);
            }
        }
    }

    shuf(list.items);
    const len = blk: {
        var len_str = args.option("-n") orelse break :blk list.items.len;
        var len = std.fmt.parseUnsigned(usize, len_str, 10) catch {
            try std.io.getStdErr().writer().print("invalid number of lines", .{});
            os.exit(1);
        };
        break :blk std.math.min(len, list.items.len);
    };
    for (list.items[0..len]) |line| {
        var stdout = std.io.getStdOut().writer();
        try stdout.writeAll(line);
        try stdout.writeAll("\n");
    }
}

fn walk(dir: fs.Dir, ally: *mem.Allocator, list: *ArrayListUnmanaged([]const u8), filter: *Regex) anyerror!void {
    var itr = dir.iterate();
    while (try itr.next()) |entry| {
        switch (entry.kind) {
            .Directory => {
                var next = try dir.openDir(entry.name, .{ .iterate = true });
                try walk(next, ally, list, filter);
            },
            .File => {
                if (!(try filter.match(entry.name))) continue;
                // TODO reduce error set to exclude not a file.
                var file = try dir.openFile(entry.name, .{ .read = true });
                while (file.reader().readUntilDelimiterAlloc(ally, '\n', 10 * mem.page_size)) |line| {
                    try list.append(ally, line);
                } else |err| switch (err) {
                    error.EndOfStream => {},
                    else => return err,
                }
            },
            else => {},
        }
    }
}

fn shuf(items: [][]const u8) void {
    var prng = rand.DefaultPrng.init(@intCast(u64, std.time.timestamp()));
    for (items) |_, i| {
        var idx = prng.random.uintLessThanBiased(usize, items.len);
        var t = items[i];
        items[i] = items[idx];
        items[idx] = items[i];
    }
}
