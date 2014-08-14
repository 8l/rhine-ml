{
  open Parser
  exception SyntaxError of string
}

let digit = ['0'-'9']
let characters = ['a'-'z' 'A'-'Z']
let symbol_characters = ['a'-'z' 'A'-'Z' '?' '-' '+' '*' '/' '<' '>' '=' '.']
let e = ['E''e']['-''+']?['0'-'9']+

rule token = parse
 | [' ' '\t' '\r' '\n'] { token lexbuf }
 | ";;" { comment lexbuf }
 | '(' { LPAREN }
 | ')' { RPAREN }
 | '[' { LSQBR }
 | ']' { RSQBR }
 | "nil" { NIL }
 | "true" { TRUE }
 | "false" { FALSE }
 | (['0'-'9']*)'.'['0'-'9']+e? as s { DOUBLE(float_of_string s) }
 | (['0'-'9']+)'.'['0'-'9']*e? as s { DOUBLE(float_of_string s) }
 | (['0'-'9']+)e as s { DOUBLE(float_of_string s) }

 | ['-''+']?digit+ as s { INTEGER(int_of_string s) }
 | symbol_characters+ as s { SYMBOL(s) }
 | '"' { let b = Buffer.create 1024 in read_string b lexbuf }
 | eof { EOF }

and comment = parse
 '\n' { token lexbuf }
 | _ { comment lexbuf }

and read_string b = parse
 "\\\"" { Buffer.add_string b "\""; read_string b lexbuf }
 | '"' { STRING(Buffer.contents b) }
 | [^'"'] { Buffer.add_string b (Lexing.lexeme lexbuf); read_string b lexbuf }
