%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
};

typedef struct
{
	string nomeVariavel;
	string tipoVariavel;
} TIPO_SIMBOLO;

int var_temp_qnt;
vector<TIPO_SIMBOLO> tabelaSimbolos;

int yylex(void);
void yyerror(string);
string generator_temp_code();
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR 

%start S

%left '+'
%left '-'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador BRABO*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS 
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';' 
			| TK_TIPO_INT TK_ID ';'
			{
				TIPO_SIMBOLO valor;
				valor.nomeVariavel = $2.label;
				valor.tipoVariavel = "int";

				tabelaSimbolos.push_back(valor);

				$$.traducao = "";
				$$.label = "";
			}
			;

E 			: E '+' E
			{
				$$.label = generator_temp_code();
				$$.traducao = $1.traducao + $3.traducao + 
					"\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			|
			E '-' E
			{
				$$.label = generator_temp_code();
				$$.traducao = $1.traducao + $3.traducao + 
					"\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}
			| TK_ID '=' E 
			{
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.label = generator_temp_code();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				bool encontrei = false;
				TIPO_SIMBOLO variavel;
				for (int i = 0; i < tabelaSimbolos.size(); i++){
					if(tabelaSimbolos[i].nomeVariavel == $1.label) {
						variavel = tabelaSimbolos[i];
						encontrei = true;
					}
				}

				if (!encontrei) {
					yyerror("Você não declarou a variavel");
				}
				$$.label = generator_temp_code();
				$$.traducao = "\t" + variavel.tipoVariavel + " " + $$.label + " = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string generator_temp_code() 
{
	var_temp_qnt++;
	return "t" + std::to_string(var_temp_qnt);
}

int main( int argc, char* argv[] )
{
	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
