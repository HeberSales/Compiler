/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TK_NUM = 258,
    TK_REAL = 259,
    TK_CHAR = 260,
    TK_MAIN = 261,
    TK_ID = 262,
    TK_TIPO_INT = 263,
    TK_TIPO_FLOAT = 264,
    TK_TIPO_BOOLEAN = 265,
    TK_TIPO_CHAR = 266,
    TK_TRUE = 267,
    TK_FALSE = 268,
    TK_MAIOR_IGUAL = 269,
    TK_MENOR_IGUAL = 270,
    TK_IGUAL_IGUAL = 271,
    TK_DIFERENTE = 272,
    TK_MAIS_MAIS = 273,
    TK_MENOS_MENOS = 274,
    TK_OU = 275,
    TK_E = 276,
    TK_FIM = 277,
    TK_ERROR = 278
  };
#endif
/* Tokens.  */
#define TK_NUM 258
#define TK_REAL 259
#define TK_CHAR 260
#define TK_MAIN 261
#define TK_ID 262
#define TK_TIPO_INT 263
#define TK_TIPO_FLOAT 264
#define TK_TIPO_BOOLEAN 265
#define TK_TIPO_CHAR 266
#define TK_TRUE 267
#define TK_FALSE 268
#define TK_MAIOR_IGUAL 269
#define TK_MENOR_IGUAL 270
#define TK_IGUAL_IGUAL 271
#define TK_DIFERENTE 272
#define TK_MAIS_MAIS 273
#define TK_MENOS_MENOS 274
#define TK_OU 275
#define TK_E 276
#define TK_FIM 277
#define TK_ERROR 278
#define TK_IF = 279
#define TK_ELSE = 280
#define TK_WHILE = 281
#define TK_FOR = 282
#define TK_DO = 283
#define TK_SWITCH = 284
#define TK_CASE = 285


/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
