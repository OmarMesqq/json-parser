// Performs lexical analysis (tokenization)
const std = @import("std");
const ArrayList = std.ArrayList;
const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const LexicalError = @import("errors.zig").LexicalError;
const buildConfig = @import("config");

pub const Lexer = struct {
    input: []const u8,
    tokens: ArrayList(Token),
    allocator: *std.mem.Allocator,
    position: usize,
    comptime debugEnabled: bool = buildConfig.debugOption,

    pub fn init(input: []const u8, allocator: *std.mem.Allocator) Lexer {
        return Lexer{ .input = input, .allocator = allocator, .tokens = ArrayList(Token).init(allocator.*), .position = 0 };
    }

    fn tokenizeString(self: *Lexer) ![]const u8 {
        const start = self.position + 1;
        var end = start;

        while (true) {
            if (end >= self.input.len) {
                if (comptime self.debugEnabled) {
                    std.debug.print("[L] String tokenized from position {d} to {d}.\n", .{ start - 1, end });
                }
                std.debug.print("[L] End of input reached without closing quotation mark.\n", .{});
                return LexicalError.UnexpectedEndOfString;
            }
            if (self.input[end] == '"') {
                break;
            }
            end += 1;
        }

        self.position = end + 1; // Move past the closing quotation mark
        if (comptime self.debugEnabled) {
            std.debug.print("[L] String tokenized from position {d} to {d}.\n", .{ start - 1, end });
        }

        return self.input[start..end];
    }

    fn isDigitOrNumberPart(c: u8, isFirstChar: bool) bool {
        return (c >= '0' and c <= '9') or
            (isFirstChar and (c == '-' or c == '+')) or
            (c == '.' or c == 'e' or c == 'E');
    }

    fn tokenizeNumber(self: *Lexer) ![]const u8 {
        const start = self.position;
        var end = start;

        while (end < self.input.len) {
            const c = self.input[end];
            if (!isDigitOrNumberPart(c, end == start)) {
                break;
            }
            end += 1;
        }

        if (start == end) {
            return LexicalError.UnexpectedEndOfNumber;
        }

        self.position = end; // Update position to the next character after the number

        if (comptime self.debugEnabled) {
            std.debug.print("[L] Number tokenized from position {d} to {d}.\n", .{ start, end - 1 });
        }

        return self.input[start..end];
    }

    fn startsWith(self: *Lexer, currentPosition: usize, literal: []const u8) bool {
        // Do not read beyond the input's length
        if (currentPosition + literal.len > self.input.len) {
            return false;
        }
        return std.mem.eql(u8, self.input[currentPosition .. currentPosition + literal.len], literal);
    }

    pub fn tokenize(self: *Lexer) !ArrayList(Token) {
        if (self.input.len == 0) {
            return LexicalError.EmptyFile;
        }

        while (self.position < self.input.len) {
            const token = self.input[self.position];

            if (token == ' ' or token == '\n' or token == '\r' or token == '\t') {
                self.position += 1;
                if (comptime self.debugEnabled) {
                    std.debug.print("[L] Skipped whitespace\n", .{});
                }
                continue;
            } else if (token == '{') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.ObjectStart });
                self.position += 1;
            } else if (token == '"') {
                const string = try self.tokenizeString();
                try self.tokens.append(Token{ .lexeme = string, .ttype = TokenType.String });
            } else if (token == '}') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.ObjectEnd });
                self.position += 1;
            } else if (token == '[') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.ArrayStart });
                self.position += 1;
            } else if (token == ']') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.ArrayEnd });
                self.position += 1;
            } else if (token == ':') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.Colon });
                self.position += 1;
            } else if (token == ',') {
                try self.tokens.append(Token{ .lexeme = self.input[self.position .. self.position + 1], .ttype = TokenType.Comma });
                self.position += 1;
            } else if (token >= '0' and token <= '9') {
                const number = try self.tokenizeNumber();
                try self.tokens.append(Token{ .lexeme = number, .ttype = TokenType.Number });
                self.position += 1;
            } else if (self.startsWith(self.position, "null")) {
                self.position += 4;
                try self.tokens.append(Token{ .lexeme = "null", .ttype = TokenType.Null });
            } else if (self.startsWith(self.position, "false")) {
                self.position += 5;
                try self.tokens.append(Token{ .lexeme = "false", .ttype = TokenType.False });
            } else if (self.startsWith(self.position, "true")) {
                self.position += 4;
                try self.tokens.append(Token{ .lexeme = "true", .ttype = TokenType.True });
            } else {
                self.position += 1;
                std.debug.print("[L] Unknown character! ASCII code: {d}\n", .{token});
                return LexicalError.UnknownToken;
            }
            if (comptime self.debugEnabled) {
                std.debug.print("[L] Analyzed character {c} at position {d}\n", .{ token, self.position });
            }
        }
        return self.tokens;
    }
};
