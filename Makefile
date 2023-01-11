all: lex yacc 
	g++ lex.yy.c y.tab.c -ll -o project

yacc: project.y
	yacc -d -v project.y

lex: project.l
	lex project.l

clean: lex.yy.c y.tab.c project y.tab.h
	rm lex.yy.c y.tab.c project y.tab.h

run: 
	./project input.txt