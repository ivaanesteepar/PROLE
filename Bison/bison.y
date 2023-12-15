/**
* Autores:
*
* -Jimena Arnaiz González
* -Iván Estépar Rebollo
**/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int getNextNumber(); //Función para obtener el siguiente número único
void yyerror(const char *s); //Función para manejar errores de análisis
extern int yylex(); //Declaración de la función de análisis léxico generada por Flex
int cont = 1;

FILE *yyin; //Para manejar el archivo de entrada
%}

//Unión para manejar los distintos tipos de datos 
%union {
    int num; //Para números
    char* id; //Para identificadores (ID)
    int etiq; //PAra etiquetas
}

//Definición de tokens
%token DO WHILE ABRIR CERRAR FOR FROM TO IF ELSE BY READ PRINT pCOMA aKEY cKEY ASS ADD SUB MUL DIV 
       <num>NUM <id>ID //añadir el <tipo> nos permite no tener que especificarlo luego en los $ de la misma pruducción

//Asociatividad a izquierdas y prioridad de operadores
%left '+' '-' 
%left '*' '/' //mayor prioridad por estar más cerca del código

%%

//Regla principal del programa
program: stmts ;

//Reglas para las declaraciones
stmts: stmt pCOMA stmts | stmt ;

// Reglas para una declaración (que puede ser un bucle, condición, asignación o entrada/salida)
stmt:  loop
     | cond
     | assig
     | io
     ;

//Reglas para bucles do-while y for
loop:  DO {$<etiq>$=getNextNumber(); //el num de las etiquetas se consigue llamando a la función obtener siguiente num y lo dejamos en el tope de pila con $$
   	   printf("LBL%d:\n", $<etiq>$);
	  } 
      	 stmts 
       WHILE ABRIR expr CERRAR { $<etiq>$=getNextNumber(); 
				 printf("\tsifalsovea LBL%d\n\tvea LBL%d\nLBL%d:\n", $<etiq>$, $<etiq>2, $<etiq>$);
			       }
     | FOR ABRIR ID { printf("\tvalori %s\n", $<id>3); }
       FROM expr { printf("\tasigna\n"); }
       TO NUM { $<etiq>$ = getNextNumber(); }
       optional_by CERRAR { $<etiq>$ = getNextNumber(); printf("LBL%d:\n", $<etiq>$); }
       aKEY stmts cKEY {
    			printf("\tvalori %s\n", $<id>3);
    			printf("\tvalord %s\n", $<id>3);
    			printf("\tmete %d\n", cont);
   			printf("\tadd\n");
    			printf("\tasigna\n");
    			printf("\tmete %d\n", $9);
    			printf("\tvalord %s\n", $3);
    			printf("\tsub\n");
    			$<etiq>$ = getNextNumber(); printf("\tsifalsovea LBL%d\n", $<etiq>$);
    			printf("\tvea LBL%d\n", $<etiq>13);
    			printf("LBL%d:\n", $<etiq>$);
		       }
     ;

// Para quitar los problemas de reducción/reducción en los for
optional_by:
   	    | BY NUM { cont = $<num>2; }
    	    ;

//Regla para condicionales (if-else)
cond:  IF ABRIR expr CERRAR sifalsovea
 	 aKEY stmts cKEY  { printf("LBL%d:\n", $<etiq>5); } //poniendo $<etiq>5 accedemos al valor de la etiq del tope de pila de sifalsovea 
     | 
	IF ABRIR expr CERRAR sifalsovea 
	 aKEY stmts cKEY  
       ELSE aKEY { $<etiq>$=getNextNumber(); printf("\tvea LBL%d\n", $<etiq>$);
		   printf("LBL%d:\n", $<etiq>5 );
		 }
	 stmts cKEY { printf("LBL%d:\n", $<etiq>11); }
     ;

//Para quitar los problemas de reduccion/reduccion en los if
sifalsovea : { $<etiq>$=getNextNumber(); printf("\tsifalsovea LBL%d\n", $<etiq>$); }

//Regla para entrada/salida
io:   PRINT expr { printf("\tprint\n"); }
    | READ ID { printf("\tread %s\n", $2); }
    ;

//Regla para asignaciones de distintos tipos
assig: ID { printf("\tvalori %s\n", $<id>1); } ASS expr { printf("\tasigna\n"); }
     | ID { printf("\tvalori %s\n", $<id>1); } ADD { printf("\tvalord %s\n", $<id>1);} expr { printf("\tadd\n\tasigna\n"); }
     | ID { printf("\tvalori %s\n", $<id>1); } SUB { printf("\tvalord %s\n", $<id>1);} expr { printf("\tsub\n\tasigna\n"); }
     | ID { printf("\tvalori %s\n", $<id>1); } MUL { printf("\tvalord %s\n", $<id>1);} expr { printf("\tmul\n\tasigna\n"); }
     | ID { printf("\tvalori %s\n", $<id>1); } DIV { printf("\tvalord %s\n", $<id>1);} expr { printf("\tdiv\n\tasigna\n"); }
     ;

//Regla para expresiones
expr:  expr '+' mult { printf("\tadd\n"); }
     | expr '-' mult { printf("\tsub\n"); }
     | mult
     ;

//Regla para multiplicaciones y divisiones
mult:  mult '*' val { printf("\tmul\n"); }
     | mult '/' val { printf("\tdiv\n"); }
     | val
     ;

//Regla para valores
val:  NUM { printf("\tmete %d\n", $1); } //se carga el número en la pila
    | ID { printf("\tvalord %s\n", $1); } //se carga el identificador en la pila
    | ABRIR expr CERRAR
    ;

%%

// Función para manejar errores de análisis
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

//Main del programa
int main(int argc, char *argv[]) {
    if (argc == 2) { //Verifica si se proporciona un archivo como argumento
        yyin = fopen(argv[1], "r"); //lo abre para lectura
        if (!yyin) {
            perror("Error opening file");
            exit(EXIT_FAILURE);
        }
    } else { //si no se proporciona un fichero, usa la entrada por teclado
        yyin = stdin;
    }

    yyparse(); //comienza el análisis sintáctico

    if (argc == 2) {
        fclose(yyin); //cierra el archivo
    }

    return 0;
}

//Función para obtener el siguiente número único
int getNextNumber() {
    static int nextNumber = 0;
    return nextNumber++;
}
