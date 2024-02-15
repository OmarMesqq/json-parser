pub const TokenType = enum { ObjectStart, ObjectEnd, ArrayStart, ArrayEnd, String, Colon, Comma, Number, Null, True, False };
pub const Token = struct { lexeme: []const u8, ttype: TokenType };
