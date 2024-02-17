// Performs syntactic analysis (parsing) on a stream of tokens
const std = @import("std");
const ArrayList = std.ArrayList;
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const SyntacticError = @import("errors.zig").SyntacticError;

pub const Parser = struct {
    tokens: ArrayList(Token),
    allocator: *std.mem.Allocator,
    index: usize,

    pub fn init(allocator: *std.mem.Allocator, tokens: ArrayList(Token)) Parser {
        var parser = Parser{ .allocator = allocator, .tokens = ArrayList(Token).init(allocator.*), .index = 0 };

        for (tokens.items) |token| {
            parser.tokens.append(token) catch unreachable;
        }

        return parser;
    }

    fn parseObject(self: *Parser) SyntacticError!void {
        self.index += 1; // Skip ObjectStart
        while (self.tokens.items[self.index].ttype != TokenType.ObjectEnd) {
            try self.parsePair();
            if (self.tokens.items[self.index].ttype == TokenType.Comma) {
                self.index += 1; // Skip Comma
                if (self.tokens.items[self.index].ttype == TokenType.ObjectEnd) {
                    return error.TrailingComma;
                }
            }
        }
        self.index += 1; // Skip ObjectEnd
    }

    fn parseArray(self: *Parser) SyntacticError!void {
        self.index += 1; // Skip ArrayStart
        while (self.tokens.items[self.index].ttype != TokenType.ArrayEnd) {
            try self.parseValue();
            if (self.tokens.items[self.index].ttype == TokenType.Comma) {
                self.index += 1; // Skip Comma
            }
        }
        self.index += 1; // Skip ArrayEnd
    }

    fn parsePair(self: *Parser) SyntacticError!void {
        // Expect a string as the key
        if (self.tokens.items[self.index].ttype != TokenType.String) {
            return error.InvalidKey;
        }
        self.index += 1; // Skip Key (String)

        // Expect a colon
        if (self.tokens.items[self.index].ttype != TokenType.Colon) {
            return error.NoColonFound;
        }
        self.index += 1; // Skip Colon

        // Parse the value
        try self.parseValue();
    }

    fn parseValue(self: *Parser) SyntacticError!void {
        switch (self.tokens.items[self.index].ttype) {
            TokenType.ObjectStart => try self.parseObject(),
            TokenType.ArrayStart => try self.parseArray(),
            TokenType.String, TokenType.Number, TokenType.True, TokenType.False, TokenType.Null => self.index += 1, // Just move forward for these types
            else => return error.NotObjectNorArray,
        }
    }

    // Recursive descent parser
    pub fn parse(self: *Parser) SyntacticError!void {
        std.debug.print("[P] Size of tokens array: {d}\n", .{self.tokens.items.len});

        while (self.index < self.tokens.items.len) {
            var current = self.tokens.items[self.index].ttype;

            if (current == TokenType.ObjectStart) {
                try self.parseObject();
            } else if (current == TokenType.ArrayStart) {
                try self.parseArray();
            } else {
                unreachable;
            }
        }
    }
};
