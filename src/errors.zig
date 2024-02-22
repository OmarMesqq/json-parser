pub const LexicalError = error{ UnknownToken, EmptyFile, UnexpectedEndOfString, UnexpectedEndOfNumber };
pub const SyntacticError = error{ InvalidKey, NotObjectNorArray, NoColonFound, TrailingComma };
