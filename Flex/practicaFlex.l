/**
* Práctica de FLEX
* Autores-> Jimena Arnaiz González e Iván Estépar Rebollo
**/

%{  
int cont = 0;
float  min, max;
char *titulo;
char func[100];
%}

%x TITLE DOMAIN DCHA PLOT FUNC COORD XMAX XMIN

%%
title=[ \t]*"{" {BEGIN(TITLE);}
<TITLE>[^}]+ {titulo = strdup(yytext);}
<TITLE>"}" {BEGIN(INITIAL);}

xmin= {BEGIN(XMIN);}
<XMIN>[+-]?[0-9]+ { float num = atoi(yytext);
if (num >  min) {
       min =  num;
}}
<XMIN>, {BEGIN(INITIAL);}

xmax= {BEGIN(XMAX);}
<XMAX>[+-]?[0-9]+ {
float num = atoi(yytext);
if (num >  max) {
       max =  num;
}}
<XMAX>, {BEGIN(INITIAL);}

\\addplot[ \t]*"[" {BEGIN(PLOT); cont++;}
<PLOT>domain= {BEGIN(DOMAIN);}
<DOMAIN>[+-]?[0-9]+ {
float num = atoi(yytext);
if (num < min) {
       min =  num;
}}
<DOMAIN>: {BEGIN(DCHA);}

<DCHA>[+-]?[0-9]+ {
float num = atoi(yytext);
if (num >  max) {
       max =  num;
}}
<DCHA>, {BEGIN(PLOT);}

<PLOT>"{" {BEGIN(FUNC);}

<FUNC>[^}]+ {if (yyleng> strlen(func)){
 strcpy(func,yytext);}}
<FUNC>"}" {BEGIN(INITIAL);}


coordinates[ \t]*"{" {BEGIN(COORD);}
<COORD>[^}]+ {if (yyleng> strlen(func)){
strcpy(func, yytext);
}}
<COORD>"}" {BEGIN(INITIAL);}

<*>.|\n ;

%%
int main(int argc, char *argv[]) {
    if (argc > 1) { 
        FILE *file;
        file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "no se puede abrir %s\n", argv[1]);
            exit(1);
        }
        yyin = file;
        yylex();
        fclose(file);
	if(titulo != NULL){
       		printf("El título es: %s\n", titulo);
	}else{
		printf("El título es: \"\"\n");
        }
	printf("Coordenada mínima: %.2f y máxima: %.2f\n", min, max);
        printf("El gráfico contiene %d gráficas/series\n", cont);
	printf("La ecuación más larga es: %s\n", func);
    }
    return 0;
}
