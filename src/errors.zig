pub const LexicalError = error{ UnknownToken, EmptyInput, UnexpectedEndOfString, UnexpectedEndOfNumber };
pub const SyntacticError = error{ InvalidKey, NotObjectNorArray, NoColonFound, TrailingComma };
