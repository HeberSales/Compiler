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
				$$.label = generator_temp_code();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
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
	TIPO_SIMBOLO valor;
	valor.nomeVariavel = "score";
	valor.tipoVariavel = "int";
	cout << valor.nomeVariavel << endl;

	tabelaSimbolos.push_back(valor);
	cout << tabelaSimbolos.size() << endl;
	cout << tabelaSimbolos[0].nomeVariavel << endl;

	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
