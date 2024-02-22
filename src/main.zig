const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;
const ArrayList = std.ArrayList;
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const buildConfig = @import("config");

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.heap.page_allocator.free(args);

    if (args.len != 2) {
        std.debug.print("Usage: json_parser <filename>\n", .{});
        if (args.len < 2) {
            std.debug.print("Not enough arguments. Missing filename.\n", .{});
            return;
        }
        if (args.len > 2) {
            std.debug.print("Too many arguments. Specify only one JSON file.\n", .{});
            return;
        }
    }

    const filename = args[1];

    const file = try std.fs.cwd().openFile(filename, .{
        .mode = .read_only,
    });
    defer file.close();

    const file_stat = try file.stat();
    const file_size = file_stat.size;

    var buffer = try std.heap.page_allocator.alloc(u8, file_size);
    defer std.heap.page_allocator.free(buffer);

    const reader = file.reader();
    _ = try reader.read(buffer);

    const fileContents = std.mem.sliceTo(buffer, 0); // search the buffer until null terminator

    var lexer = Lexer.init(fileContents, &allocator);
    const tokenList = lexer.tokenize() catch |err| {
        std.debug.print("Error during tokenization!\n{any}\n", .{err});
        return;
    };

    if (comptime buildConfig.debugOption) {
        try printTokens(tokenList);
    }

    var parser = Parser.init(&allocator, tokenList);
    _ = parser.parse() catch |err| {
        std.debug.print("Invalid JSON!\n{any}\n", .{err});
        return;
    };

    std.debug.print("Valid JSON.\n", .{});
}

fn printTokens(tokens: ArrayList(Token)) !void {
    for (tokens.items) |token| {
        // Assumes lexeme is UTF-8 encoded and valid for the types specified
        if (token.ttype == TokenType.String or token.ttype == TokenType.Number or
            token.ttype == TokenType.Null or token.ttype == TokenType.True or
            token.ttype == TokenType.False)
        {
            std.debug.print("[L] Token: {any}, Lexeme: \"{s}\"\n", .{ token.ttype, token.lexeme });
        } else {
            std.debug.print("[L] Token: {any}\n", .{token.ttype});
        }
    }
}
