D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			([Ee][+-]?{D}+)
P     ([Pp][+-]?{D}+)
FS		(f|F|l|L)
IS    ((u|U)|(u|U)?(l|L|ll|LL)|(l|L|ll|LL)(u|U))
%%
","  { return(','); }
"="  { return('='); }
"?"  { return('?'); }
":"  { return(':'); }
"|"  { return('|'); }
"^"  { return('^'); }
"&"  { return('&'); }
"<"  { return('<'); }
">"  { return('>'); }
"+"  { return('+'); }
"-"  { return('-'); }
"*"  { return('*'); }
"/"  { return('/'); }
"%"  { return('%'); }
"sizeof"  { return(SIZEOF); }
"~"  { return('~'); }
"!"  { return('!'); }
"await"  { return(AWAIT); }
"+="  { return(OP1); }
"-="  { return(OP2); }
"*="  { return(OP3); }
"/="  { return(OP4); }
"%="  { return(OP5); }
"<<="  { return(OP6); }
">>="  { return(OP7); }
"&="  { return(OP8); }
"^="  { return(OP9); }
"|="  { return(OP10); }
"||"  { return(OP11); }
"&&"  { return(OP12); }
"=="  { return(OP13); }
"=!"  { return(OP14); }
"<="  { return(OP15); }
">="  { return(OP16); }
"(type_name)"  { return(OP17); }
"++"  { return(OP20); }
"--"  { return(OP21); }
{L}({L}|{D})*		{ return(IDENTIFIER); }
