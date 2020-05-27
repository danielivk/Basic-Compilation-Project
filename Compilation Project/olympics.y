%code
{
	/* includes */
	#include <stdio.h> 
	#include <string.h>
	#include <stdlib.h> 

	/* prototypes */
	extern int yylex(void);
	void yyerror(const char *s);

	void printResults(SportList* sl);
	void yearNumCheck(int num);
	void yearSequenceCheck (int left, int right);
	void freeAll(SportList *sl);
}


/* defines */
%code requires 
{
	#define N 20
	#define FIRST 1896
	#define LAST 2016
	#define calculateHowManyOlympics(y1, y2) ((y1 - y2) / 4 + 1)

	/* tells bison to create output file */
	#define YYDEBUG 1
} 


/* structs */
%code requires 
{
	typedef struct  
	{
		char *name;
		int olympicAppearanceNum; 
	} Sport;

	typedef struct  
	{
		Sport sports[N];
		int numOfSports;
		double yearsCalculator; 
	} SportList;
}


/* yyval */
%union 
{
  int ival;
  char c;
  char str[N];
  SportList sl;
  Sport s;
}


/* TERMINALS */
%token <ival> YEAR_NUM SINCE_YEAR_NUM 
%token <c> COMMA THROUGH
%token <str> TITLE SPORT NAME SINCE YEARS ALL


/* Semantic Values */
%type <ival> year_spec list_of_years
%type <s> sport_info
%type <sl> input list_of_sports


%error-verbose
%%

line: input 
	{
		printResults(&$1);
		freeAll(&$1);
	};

input: TITLE list_of_sports 
	{
		$$ = (SportList) $2;
		$$.yearsCalculator /= $$.numOfSports;
	};

/* semantic value is the SportList Struct of all the sports */
list_of_sports: list_of_sports sport_info
	{	
		if ($1.numOfSports < N)
		{
			$1.sports[$1.numOfSports++] = (Sport) { $2.name, $2.olympicAppearanceNum };
			$1.yearsCalculator += $2.olympicAppearanceNum;
		}

		$$ = $1;				
	};

list_of_sports: { /* empty */ };

/* semantic value is the Sport Struct for that sport */
sport_info: SPORT NAME YEARS list_of_years
	{		
		$$.name = strdup((char*) $2);
		$$.olympicAppearanceNum = (int) $4;		
	};

/* semantic value is the total number of olympic games played for that sport */
list_of_years: list_of_years COMMA year_spec { $$ = ((int) $1 + (int) $3); };

/* semantic value is the total number of olympic games played for that sport */
list_of_years: year_spec { $$ = (int) $1; };

/* semantic value is the number of olympic games played for a range of years */
year_spec:

	YEAR_NUM	
	{
		if ($1 == 2020 || $1 == 2021)
		{
			$$ = 0;
		}
		else
		{
			yearNumCheck((int) $1);
			$$ = 1;
		}
	} |

 	ALL 
	{
 		$$ = calculateHowManyOlympics(LAST, FIRST);
 	} |
 	   
	YEAR_NUM THROUGH YEAR_NUM
	{
		yearSequenceCheck((int) $1, (int) $3);
		$$ = calculateHowManyOlympics((int) $3, (int) $1);
	} |

 	SINCE YEAR_NUM
	{
		yearNumCheck((int) $2);
		$$ = calculateHowManyOlympics(LAST, (int) $2);
	};

%%


int main(int argc, char **argv)
{
  extern FILE *yyin;

  if (argc != 2) 
  {
     fprintf(stderr, "Usage: %s <input-file-name>\n", argv[0]);
     return 1;
  }

  yyin = fopen (argv [1], "r");

  if (yyin == NULL) 
  {
     fprintf(stderr, "failed to open %s\n", argv[1]);
     return 2;
  }
  
  yyparse();
  
  fclose(yyin);
  return 0;
}


void yyerror(const char *s) { printf("\nyyerror: %s\n", s); }

void printResults(SportList* sl)
{
	int i;  

	printf("\n\nsports which appeared in at least 7 olympic games:\n");

	for (i = 0; i < sl->numOfSports; i++)
	{
		printf ("%s\n", (sl->sports)[i].name);
	}

	printf("\naverage number of games per sport: %.2f\n\n\n", sl->yearsCalculator);
}

void yearNumCheck(int num)
{
	if (num < FIRST)
	{
		fprintf(stderr, "Invalid year number (%d < %d)", num, FIRST);
		exit(1);
	}
	else if (num > LAST)
	{
		fprintf(stderr, "Invalid year number (%d > %d)", num, LAST);
		exit(1);
	}
}

void yearSequenceCheck(int left, int right)
{
	if (left < FIRST || right < FIRST + 4 || left > LAST - 4 || right > LAST)
	{
		fprintf(stderr, "Invalid year sequence %d - %d)", left, right);
		exit(1);
	}
}

void freeAll(SportList *sl)
{
	int i;
	for (i = 0; i < sl->numOfSports; i++)
	{
		free((char*) sl->sports[i].name);
	}
}









