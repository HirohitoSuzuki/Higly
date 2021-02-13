%%
"]"  { return(']'); }
"["  { return('['); }
"."  { return('.'); }
"new"  { return(NEW); }
"delete"  { return(DELETE); }
"void"  { return(VOID); }
"typeof"  { return(TYPEOF); }
"+"  { return('+'); }
"-"  { return('-'); }
"~"  { return('~'); }
"!"  { return('!'); }
"await"  { return(AWAIT); }
"*"  { return('*'); }
"/"  { return('/'); }
"%"  { return('%'); }
"<"  { return('<'); }
">"  { return('>'); }
"instanceof"  { return(INSTANCEOF); }
"in"  { return(IN); }
"&"  { return('&'); }
"^"  { return('^'); }
"|"  { return('|'); }
"?"  { return('?'); }
":"  { return(':'); }
"="  { return('='); }
","  { return(','); }
"++"  { return(OP1); }
"--"  { return(OP2); }
"**"  { return(OP3); }
"<<"  { return(OP4); }
">>"  { return(OP5); }
">>>"  { return(OP6); }
"<="  { return(OP7); }
">="  { return(OP8); }
"=="  { return(OP9); }
"=!"  { return(OP10); }
"==="  { return(OP11); }
"!=="  { return(OP12); }
"&&"  { return(OP13); }
"||"  { return(OP14); }
"*="  { return(OP15); }
"/="  { return(OP16); }
"%="  { return(OP17); }
"+="  { return(OP18); }
"-="  { return(OP19); }
"<<="  { return(OP20); }
">>="  { return(OP21); }
">>>="  { return(OP22); }
"&="  { return(OP23); }
"^="  { return(OP24); }
"|="  { return(OP25); }
"**="  { return(OP26); }
"||="  { return(OP27); }
"??="  { return(OP28); }
[a-zA-Z_]([a-zA-Z_]|[0-9])*  { return (IDENTIFIER);}
0                            { return(INT_LITERAL); }
[1-9][0-9]*                  { return(INT_LITERAL); }
[0-9]+"."[0-9]+              { return(FLOAT_LITERAL); }
\"[^\"\n]*\"                 { return(STRING_LITERAL); }