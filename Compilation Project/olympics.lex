%{

#include <string.h> 
#include "olympics.tab.h"

extern int atoi (const char *);

%}


%option noyywrap

%%

[\n\t \r]+  /* skip white space */

"since" { strcpy (yylval.str, yytext); return SINCE; }

"-"|"through" { yylval.c = '-'; return THROUGH; }

"all" { strcpy (yylval.str, yytext); return ALL; }

"<sport>" { strcpy (yylval.str, yytext); return SPORT; }

\"[a-zA-Z]{2,}[a-zA-Z ]*[a-zA-Z]{2,}\" { strcpy (yylval.str, yytext + 1); yylval.str[strlen(yytext) - 2] = '\0'; return NAME; }

(189[6789])|(19[0-9][0-9])|(20[0-1][0-9]) { yylval.ival = atoi (yytext); return YEAR_NUM; }
"2020"   { yylval.ival = 2021; return YEAR_NUM; }

"," { yylval.c = ','; return COMMA; }

"<years>" { strcpy (yylval.str, yytext); return YEARS; }

[a-zA-Z]{2,}[a-zA-Z ]*[a-zA-Z]{2,} { strcpy (yylval.str, yytext); return TITLE; }

. { fprintf (stderr, "unrecognized token begins with char '%c'\n", yytext[0]); exit(0); }

%%

