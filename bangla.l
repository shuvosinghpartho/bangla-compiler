%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bangla.tab.h"
%}

%%

"ধরি"      { return K_INT; }
"দেখাও"    { return K_PRINT; }
"লুপ"      { return K_FOR; }
"যতক্ষণ"   { return K_WHILE; }
"যদি"      { return K_IF; }
"নাহলে"    { return K_ELSE; }

[0-9]+     { 
    yylval.ival = atoi(yytext); 
    return NUMBER;
}

"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }
"/"        { return '/'; }
"="        { return '='; }
";"        { return ';'; }
"<"        { return '<'; }
">"        { return '>'; }
"{"        { return '{'; }
"}"        { return '}'; }
"("        { return '('; }
")"        { return ')'; }
"["        { return '['; }
"]"        { return ']'; }

[ \t\n]    { /* Ignore whitespace */ }

[a-zA-Z\x80-\xff]+ {
    yylval.sval = strdup(yytext);
    return IDENTIFIER;
}

         . { printf("Unknown: %s\n", yytext); }

%%