/**
* Autores:
*
* -Jimena Arnaiz González
* -Iván Estépar Rebollo
**/

%{
#include "y.tab.h"
%}

%%

#.*\n ; //Ignora los comentarios

 /*Tokens definidos en bison que son devueltos en flex mediante el return*/
"do"        { return DO; }
"while"     { return WHILE; }
"for"       { return FOR; }
"from"      { return FROM; }
"to"        { return TO; }
"if"        { return IF; }
"else"      { return ELSE; }
"by"        { return BY; }
"read"      { return READ; }
"print"     { return PRINT; }
";"         { return pCOMA; }
"{"         { return aKEY; }
"}"         { return cKEY; }
"<:"        { return ASS; }
"\+="       { return ADD; }
"-="        { return SUB; }
"\*="       { return MUL; }
"/="        { return DIV; }
"("         { return ABRIR; }
")"         { return CERRAR; }

[ \t\r\n]   ; // Ignorar espacios en blanco, tabulaciones y saltos de línea

[0-9]+      { yylval.num = atoi(yytext); return NUM; } /*atoi() permite convertir un entero a int*/
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; } /*yyval sirve para intercambiar info. entre flex y bison*/

.           { return yytext[0]; } /*devuelve el primer carácter como token para cualquier otro caso de los definidos antes*/
