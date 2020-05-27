# Usage:
# make        # compile all binary
# make clean  # remove ALL build files and objects


# type 'make' to run the whole recipe
.PHONY: all

all: comp run clean


# Targets
comp: exp.tab.c lex.yy.c olympics

run:
	./olympics text_olympics.txt

clean: 
	rm olympics lex.yy.c olympics.tab.h olympics.tab.c olympics.output


# Compilation
exp.tab.c exp.tab.h: olympics.y
	bison -t -v -d olympics.y

lex.yy.c: olympics.lex
	flex olympics.lex

olympics: lex.yy.c olympics.tab.c olympics.tab.h
	gcc -o olympics olympics.tab.c lex.yy.c

