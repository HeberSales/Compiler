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
	string tipo;
	string valor;
};

typedef struct
{
	string nomeVariavel;
	string tipoVariavel;
	string labelVariavel;
} TIPO_SIMBOLO;

typedef struct
{
	string tipoVariavel;
	string labelVariavel;
} TIPO_TEMP;


int var_temp_qnt;

vector<TIPO_SIMBOLO> tabelaSimbolos;
vector<TIPO_TEMP> tabelaTemp;
string atribuicaoVariavel;

int yylex(void);
void yyerror(string);
string generator_temp_code();
void verificaVarRepetida(string variavel);
void verificaVarExistente(string nomeVariavel);
TIPO_SIMBOLO getSimbolo(string variavel);
void addSimbolo(string variavel, string tipo, string label);
void addTemp(string label, string tipo);
void verificarOperacaoRelacional(string tipo_1, string tipo_2);
%}

%token TK_NUM TK_REAL TK_CHAR
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOLEAN TK_TIPO_CHAR TK_TRUE TK_FALSE
%token TK_MAIOR_IGUAL TK_MENOR_IGUAL TK_IGUAL_IGUAL TK_DIFERENTE TK_MAIS_MAIS TK_MENOS_MENOS TK_OU TK_E
%token TK_FIM TK_ERROR 
%token TK_IF TK_ELSE TK_WHILE TK_FOR TK_DO TK_SWITCH

%start S

%left '+'

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
				verificaVarRepetida($2.label);
				addSimbolo($2.label, "int", generator_temp_code());

				$$.traducao = "";
				$$.label = "";
			}
			| TK_TIPO_FLOAT TK_ID ';'
			{
				verificaVarRepetida($2.label);
				addSimbolo($2.label, "float", generator_temp_code());

				$$.traducao = "";
				$$.label = "";
			}
			| TK_TIPO_BOOLEAN TK_ID ';'
			{
				verificaVarRepetida($2.label);
				addSimbolo($2.label, "boolean", generator_temp_code());

				$$.traducao = "";
				$$.label = "";
			}
			| TK_TIPO_CHAR TK_ID ';'
			{
				verificaVarRepetida($2.label);
				addSimbolo($2.label, "char", generator_temp_code());

				$$.traducao = "";
				$$.label = "";
			}
			| TK_IF '(' E ')' E ';' COMANDOS
			{
				verificarAtributoRelacional($3);
				$$.label = gentempcode();

				if(controleFunction > 0){
					traducaoFunction = traducaoFunction + "\t" + "int" + " " + $$.label +";\n";
				} else {
					atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				}

				string cond = genCondcode();

				$$.traducao = $3.traducao + "\t" 
				+ $$.label + " = !" + $3.label + ";\n" + "\t"
				"if(" + $$.label + ") goto "+ cond + "\n" + 
				$5.traducao + "\t" + cond + "\n" + $7.traducao;
			}
			| TK_IF '(' E ')' E ';' TK_ELSE E ';' COMANDOS
			{
				verificarAtributoRelacional($3);
				$$.label = gentempcode();
				if(controleFunction > 0){
					traducaoFunction = traducaoFunction + "\t" + "int" + " " + $$.label +";\n";
				} else {
					atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				}
				string cond = genCondcode();

				$$.traducao = $3.traducao + "\t" 
				+ $$.label + " = !" + $3.label + ";\n" + "\t"
				"if(" + $$.label + ") goto ELSE;" + "\n" + 
				$5.traducao + "\tgoto " + cond + "\n" + "\tELSE:\n" + $8.traducao
				+ "\t" + cond +"\n" + $10.traducao;
			}
			| TK_WHILE '(' E ')' BLOCO COMANDOS
			{
				verificarAtributoRelacional($3);
				$$.label = gentempcode();
				atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				TIPO_LOOP loop = getLace($1.label);

				$$.traducao = loop.inicioLaco + $3.traducao + "\t" + $$.label + " = !" +
				$3.label + ";\n" + "\tIF(" + $$.label + ") goto " + loop.fimLaco + "\n" +
				$5.traducao + "\tgoto " + loop.inicioLaco + "\n\t" + loop.fimLaco + "\n" + $6.traducao;
			}
			| TK_DO BLOCO TK_WHILE '(' E ')' ';' COMANDOS
			{
				verificarAtributoRelacional($5);
				$$.label = gentempcode();
				atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				TIPO_LOOP loop = getLace($1.label);

				$$.traducao = loop.inicioLaco + $2.traducao + $5.traducao + "\t" 
				+ $$.label + " = !" + $5.label + ";\n" + "\tIF(" + $$.label +") goto " 
				+ loop.fimLaco  + "\n" + "\tgoto " + loop.inicioLaco + "\n\t" + loop.fimLaco +" \n"+ $8.traducao;
			}
			| TK_FOR '(' ';' ';' ')' BLOCO COMANDOS
			{
				$$.label = gentempcode();
				atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				TIPO_LOOP loop = getLace($1.label); 

				$$.traducao = loop.inicioLaco + $6.traducao + "\t" + "goto " + loop.inicioLaco + "\n\t" + loop.fimLaco +"\n" + $7.traducao;
			}
			| TK_FOR '(' ATRIBUICAO ';' RELACIONAL ';' E ')' BLOCO COMANDOS
			{
				$$.label = gentempcode();
				atribuicaoVariavel = atribuicaoVariavel + "\t" + "int" + " " + $$.label +";\n";
				string lace = genLacecode();
				string cond = genCondcode();

				$$.traducao = $3.traducao + lace + $5.traducao + "\t" + $$.label + 
				" = !" + $5.label + ";\n\t" + "if(" + $$.label + ") goto "+ cond + "\n" + 
				$9.traducao + $7.traducao + "\tgoto " + lace + "\n\t"+ cond +"\n" + $10.traducao;
			}
			| TK_SWITCH '(' P ')' '{' CASES '}' COMANDOS
			{
				$$.traducao = $3.traducao + $6.traducao + $8.traducao;
			}
			{
				$$.traducao = "";
			}
			;

E 			: E '+' E
			{
				$$.label = generator_temp_code();
				string tipoAux;
				string labelAux;

				if($1.tipo == $3.tipo){
					$$.tipo = $1.tipo;
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " + " + $3.label + ";\n";
					addTemp($$.label, $$.tipo);
				}
				else if($1.tipo == "int" & $3.tipo == "float"){
					$$.tipo = $3.tipo;
					addTemp($$.label, $$.tipo);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $1.label + ";\n";

					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, $$.tipo);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + labelAux + " + " + $3.label + ";\n";
				}
				else if($1.tipo == "float" & $3.tipo == "int"){
					$$.tipo = $1.tipo;
					addTemp($$.label, $$.tipo);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n";
					labelAux = $$.label;
					$$.label = generator_temp_code();

					addTemp($$.label, $$.tipo);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + $1.label + " + " + labelAux + ";\n";
				}
				else{
					yyerror("Operação inválida");
				}
			}
			| E '-' E
			{
				$$.label = generator_temp_code();
				string tipoAux;
				string labelAux;
				if($1.tipo == $3.tipo){
					tipoAux = $1.tipo;
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " - " + $3.label + ";\n";
					addTemp($$.label, tipoAux);
				}
				else if($1.tipo == "int" & $3.tipo == "float"){
					tipoAux = "float";
					addTemp($$.label, tipoAux);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $1.label + ";\n";

					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, tipoAux);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + labelAux + " - " + $3.label + ";\n";
				}
				else if($1.tipo == "float" & $3.tipo == "int"){
					tipoAux = "float";
					addTemp($$.label, tipoAux);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n";

					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, tipoAux);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + $1.label + " - " + labelAux + ";\n";
				}
				else{
					yyerror("Operação inválida");
				}
			}
			| E '*' E 
			{
				$$.label = generator_temp_code();
				string tipoAux;
				string labelAux;
				if($1.tipo == $3.tipo){
					$$.tipo = $1.tipo;
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " * " + $3.label + ";\n";
					addTemp($$.label, $$.tipo);
				}
				else if($1.tipo == "int" & $3.tipo == "float"){
					$$.tipo = $3.tipo;
					addTemp($$.label, $$.tipo);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $1.label + ";\n";
					labelAux = $$.label;

					$$.label = generator_temp_code();
					addTemp($$.label, $$.tipo);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + labelAux + " * " + $3.label + ";\n";
				}
				else if($1.tipo == "float" & $3.tipo == "int"){
					$$.tipo = $1.tipo;
					addTemp($$.label, $$.tipo);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n";

					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, $$.tipo);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + $1.label + " * " + labelAux + ";\n";
				}
				else{
					yyerror("Operação inválida");
				}
			}
			| E '/' E
			{
				$$.label = generator_temp_code();
				string tipoAux;
				string labelAux;

				string aux = $3.valor;
				int count = 0;
				int ponto = 0;

				for(int i = 0; i < aux.size(); i++) {
					if(aux[i] == '.')
					{
						ponto = 1;
					}
					if(aux[i] == '0')
					{
						count++;
					}
				}

				if(count == aux.size() || (count + ponto) == aux.size()){
					yyerror("Divisão por 0, Operação inválida!");
				}

				if($1.tipo == $3.tipo){
					tipoAux = $1.tipo;
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " / " + $3.label + ";\n";
					addTemp($$.label, tipoAux);
				}
				else if($1.tipo == "int" & $3.tipo == "float"){
					tipoAux = "float";
					addTemp($$.label, tipoAux);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $1.label + ";\n";
					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, tipoAux);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + labelAux + " / " + $3.label + ";\n";
				}
				else if($1.tipo == "float" & $3.tipo == "int"){
					tipoAux = "float";
					addTemp($$.label, tipoAux);
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n";
					labelAux = $$.label;
					$$.label = generator_temp_code();
					addTemp($$.label, tipoAux);
					$$.traducao = $$.traducao + "\t"+
					$$.label + " = " + $1.label + " / " + labelAux + ";\n";
				}
				else{
					yyerror("Operação inválida");
				}
			}
			| E '%' E
			{
				$$.label = generator_temp_code();
				string tipoAux;
				string labelAux;

				if($1.tipo == "int" & $3.tipo == "int"){
					tipoAux = $1.tipo;
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = " + $1.label + " % " + $3.label + ";\n";
					addTemp($$.label, tipoAux);
				}

				else{
					yyerror("Operandos inválidos (float)");
				}
			}
			| E '>' E 
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " > " + $3.label + ";\n";
			}
			| E '<' E
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " < " + $3.label + ";\n";

			}
			| E TK_DIFERENTE E
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " != " + $3.label + ";\n";
			}
			| E TK_MAIOR_IGUAL E
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " >= " + $3.label + ";\n";
			}
			| E TK_MENOR_IGUAL E
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E TK_IGUAL_IGUAL E
			{
				verificarOperacaoRelacional($1.tipo, $3.tipo);
				$$.label = generator_temp_code();

				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " == " + $3.label + ";\n";
			}
			| E TK_OU E
			{
				$$.label = generator_temp_code();
				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " || " + $3.label + ";\n";
			}
			| E TK_E E
			{
				$$.label = generator_temp_code();
				addTemp($$.label, "boolean");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " && " + $3.label + ";\n";
			}
			| '!' E
			{
				$$.label = generator_temp_code();
				addTemp($$.label, "boolean");
				$$.traducao = $2.traducao + "\t" + 
				$$.label + " = " + "!" + $2.label + ";\n";
			}
			| TK_ID TK_MAIS_MAIS
			{
				verificaVarExistente($1.label);
				TIPO_SIMBOLO variavel_1 = getSimbolo($1.label);

				$$.traducao = $1.traducao + $2.traducao + "\t" + 
				variavel_1.labelVariavel + " = " + variavel_1.labelVariavel + " + 1" + ";\n";
			}
			| TK_ID TK_MENOS_MENOS
			{
				verificaVarExistente($1.label);
				TIPO_SIMBOLO variavel_1 = getSimbolo($1.label);

				$$.traducao = $1.traducao + $2.traducao + "\t" + 
				variavel_1.labelVariavel + " = " + variavel_1.labelVariavel + " - 1" + ";\n";
			}
			|TK_TIPO_FLOAT '(' E ')'
			{
				$$.label = generator_temp_code();
				$$.tipo  = "float";
				addTemp($$.label, $$.tipo);
				
				if($3.tipo == "int")
				{	
					$$.traducao = $3.traducao + "\t" + 
					$$.label + " = " + "(float) " + $3.label + ";\n";  
				}else
				{
					yyerror("Operacao invalida");
				}
			}
			|TK_TIPO_INT '(' E ')'
			{
				$$.label = generator_temp_code();
				$$.tipo  = "int";
				addTemp($$.label, $$.tipo);
				if($3.tipo == "float")
				{
					$$.traducao = $3.traducao + "\t" + 
					$$.label + " = " + "(int) " + $3.label + ";\n";
				}else
				{
					yyerror("Operacao invalida");
				}
			}
			| TK_ID '=' E 
			{
				verificaVarExistente($1.label);
				TIPO_SIMBOLO variavel = getSimbolo($1.label);

				if(variavel.tipoVariavel == $3.tipo){
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
				    variavel.labelVariavel + " = " + $3.label + ";\n";
				}
				else if (variavel.tipoVariavel == "int" & $3.tipo == "float")
				{
					$$.label = generator_temp_code();
					addTemp($$.label, "int");
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (int) " + $3.label + ";\n" + "\t" + 
					variavel.labelVariavel + " = " + $$.label + ";\n";
				}
				else if (variavel.tipoVariavel == "float" & $3.tipo == "int")
				{
					$$.label = generator_temp_code();
					addTemp($$.label, "float");
					$$.traducao = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n" + "\t" + 
					variavel.labelVariavel + " = " + $$.label + ";\n";
				}
				else{
					yyerror("Atribuição inválida");
				}
			}
			| TK_NUM
			{
				$$.tipo = "int";
				$$.label = generator_temp_code();

				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.valor = $1.label;
			}
			| TK_REAL
			{
				$$.tipo = "float";
				$$.label = generator_temp_code();
				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.valor = $1.label;
			}
			| TK_CHAR
			{
				$$.tipo = "char";
				$$.label = generator_temp_code();
				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID '=' TK_TRUE
			{
			    verificaVarExistente($1.label);
				TIPO_SIMBOLO variavel_1 = getSimbolo($1.label);
				$$.traducao = $1.traducao + $2.traducao + "\t" + 
				variavel_1.labelVariavel + " = 1"  + ";\n";
			}
			| TK_ID '=' TK_FALSE
			{
				verificaVarExistente($1.label);
				TIPO_SIMBOLO variavel_1 = getSimbolo($1.label);
				$$.traducao = $1.traducao + $2.traducao + "\t" + 
				variavel_1.labelVariavel + " = 0"  + ";\n";
			}
			| TK_ID
			{
				bool encontrei = false;
				TIPO_SIMBOLO variavel = getSimbolo($1.label);

				for(int i = 0; i < tabelaSimbolos.size(); i++){
					if(tabelaSimbolos[i].nomeVariavel == $1.label)
					{
						variavel = tabelaSimbolos[i];
						encontrei = true;
					}	
				}

				if(!encontrei)
				{
					yyerror("ERROR: a variavel '" + $1.label + "' não foi declarada");
				}

				$$.tipo = variavel.tipoVariavel;
				$$.label = variavel.labelVariavel;
				$$.traducao = "";
			}
			;
RELACIONAL  : E '>' E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " > " + $3.label + ";\n";
			}
			| E '<' E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " < " + $3.label + ";\n";
			}
			| E TK_MAIOR_IGUAL E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " >= " + $3.label + ";\n";
			}
			| E TK_MENOR_IGUAL E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E TK_IGUAL_IGUAL E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " == " + $3.label + ";\n";
			}
			| E TK_DIFERENTE E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " != " + $3.label + ";\n";
			}
			| E TK_OU E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " || " + $3.label + ";\n";
			}
			| E TK_E E
			{
				verificarOperacaoRelacional($1, $3);
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + 
				$$.label + " = " + $1.label + " && " + $3.label + ";\n";
			}
			| '!' E
			{
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = $2.traducao + "\t" + 
				$$.label + " = " + "!" + $2.label + ";\n";
			}
			;
ATRIBUICAO  : TK_ID '=' E
			{
				TIPO_SIMBOLO variavel = getSimbolo($1.label);

				string traduzir;
				if(variavel.tipoVariavel == $3.tipo){
					if($3.tipo == "string"){

						traduzir = $1.traducao
						+ "\tstrcpy(" + $3.label +", " + $3.valor +");\n\t" + 
						variavel.labelVariavel + " = " + "(char*) malloc(" + $3.index +");" +
						"\n\tstrcpy(" + variavel.labelVariavel +", " + $3.label +");\n";

						if(getContexto() != 0)
							$$.traducao = traduzir;
						else
							traducaoFunction += traduzir + '\n';
							
					} else {
						traduzir = $1.traducao + $3.traducao + "\t" + 
						variavel.labelVariavel + " = " + $3.label + ";\n";
						if(getContexto() != 0)
							$$.traducao = traduzir;
						else
							traducaoFunction += traduzir + '\n';
					}
				}
				else if (variavel.tipoVariavel == "int" & $3.tipo == "float")
				{
					$$.label = gentempcode();
					addTemp($$.label, "int");
					traduzir = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (int) " + $3.label + ";\n" + "\t" + 
					variavel.labelVariavel + " = " + $$.label + ";\n";

					if(getContexto() != 0)
							$$.traducao = traduzir;
						else
							traducaoFunction += traduzir + '\n';
				}
				else if (variavel.tipoVariavel == "float" & $3.tipo == "int")
				{
					$$.label = gentempcode();
					addTemp($$.label, "float");
					traduzir = $1.traducao + $3.traducao + "\t" + 
					$$.label + " = (float) " + $3.label + ";\n" + "\t" + 
					variavel.labelVariavel + " = " + $$.label + ";\n";

					if(getContexto() != 0)
							$$.traducao = traduzir;
						else
							traducaoFunction += traduzir + '\n';
				}
				else{
					error += "\033[1;31mError\033[0m - \033[1;36mLinha " + contLinha +  ":\033[0m\033[1;39m Atribuição inválida, tipos diferentes.\n";
				}
			}
			;
P 			: '(' E ')'
			{
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
				$$.label = $2.label;
			}
			| TK_NUM
			{
				$$.tipo = "int";
				$$.label = gentempcode();
				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.valor = $1.label;
			}
			| TK_REAL
			{
				$$.tipo = "float";
				$$.label = gentempcode();
				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.valor = $1.label;
			}
			| TK_CHAR
			{
				$$.tipo = "char";
				$$.label = gentempcode();
				addTemp($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_STRING
			{
				$$.tipo = "string";
				$$.label = gentempcode();
				$$.traducao = "\tstrcpy(" + $$.label +", " + $1.valor + ");\n";
				$$.index = std::to_string(addTempString($$.label, $$.valor));
			}
			| TK_TRUE
			{
				$$.tipo = "boolean";
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = "\t" + $$.label + " = " + "1" + ";\n";	
			}
			| TK_FALSE
			{
				$$.tipo = "boolean";
				$$.label = gentempcode();
				addTemp($$.label, "int");
				$$.traducao = "\t" + $$.label + " = " + "0" + ";\n";		
			}
			| TK_ID
			{
				TIPO_SIMBOLO variavel = getSimbolo($1.label);
				$$.tipo = variavel.tipoVariavel;
				$$.label = variavel.labelVariavel;
				$$.traducao = "";
			}
			| TK_PRINT '(' E ')'
			{
				$$.traducao = $3.traducao + "\t" + "cout << " + $3.label + ";\n";
			}
			| TK_SCAN '(' TK_ID ')'
			{
				TIPO_SIMBOLO variavel = getSimbolo($3.label);
				$$.traducao = $3.traducao + "\t" "STD::CIN >> " + variavel.labelVariavel + ";\n";
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

void verificarOperacaoRelacional(string tipo_1, string tipo_2){
	if(tipo_1 == "char" || tipo_2 == "char" || tipo_1 == "boolean" || tipo_2 == "boolean" || tipo_1 == "boolean" || tipo_2 == "char" || tipo_1 == "char" ||tipo_2 == "boolean")
	{
		yyerror ("Operação inválida (Relacional)");
	}
}

void verificarAtributoRelacional(atributos tipo_1){
	if(tipo_1.tipo == "char" || tipo_1.tipo == "string" || tipo_1.tipo == "void")
	{
		error += "\033[1;31mError\033[0m - \033[1;36mLinha " + contLinha +  ":\033[0m\033[1;39m Operação relacional inválida.\n";
	}
}

void verificaVarRepetida(string variavel){
	for(int i = 0; i < tabelaSimbolos.size(); i++)
	{
		if(tabelaSimbolos[i].nomeVariavel == variavel)
		{
			yyerror("Variável existente");
		}
	}
}

void verificaVarExistente(string nomeVariavel){
	bool result = false;
	for (int i = 0; i < tabelaSimbolos.size(); i++){
		if(tabelaSimbolos[i].nomeVariavel == nomeVariavel){
			result = true;
		}
	}
	
	if(!result)	{
		yyerror("ERROR: a variavel '" + nomeVariavel + "' não foi declarada");
	}
}

TIPO_SIMBOLO getSimbolo(string variavel){
	for (int i = 0; i < tabelaSimbolos.size(); i++)
	{
		if(tabelaSimbolos[i].nomeVariavel == variavel){
			return tabelaSimbolos[i];
		}					
	}
}

void addTemp(string label, string tipo){
	TIPO_TEMP valor;
	valor.labelVariavel = label;
	valor.tipoVariavel = tipo;
	tabelaTemp.push_back(valor);
	atribuicaoVariavel = atribuicaoVariavel + "\t" + valor.tipoVariavel + " " + valor.labelVariavel +";\n";
}

void addSimbolo(string variavel, string tipo, string label){
	TIPO_SIMBOLO valor;
	valor.nomeVariavel = variavel;
	valor.tipoVariavel = tipo;
	valor.labelVariavel = label;
	tabelaSimbolos.push_back(valor);
	atribuicaoVariavel = atribuicaoVariavel + "\t" + valor.tipoVariavel + " " + valor.labelVariavel +";\n";
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
