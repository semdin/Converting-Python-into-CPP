%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector>
	#include <string.h>
	#include <algorithm>
	#include <cctype>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);	
	vector<int> tabs;
	extern int linenum;
	extern int tabCounter;
	vector<string> lines;
	int tempTabCounter = 1;

    struct ifControl {
        bool closed;
		int tabCount;
		string type;
		bool filled = false;
    };
	vector<ifControl> vec;

	struct variables{
		bool type;
		string name;
		string nameType;
	};
	vector<variables> vars;
	vector<variables> varsLast;
	vector<string> tempVec;

	bool checkInVector(int target){

	    for (int x : tabs)
	    {
	        if (x == target)
	        {
	            return true;
	        }
	    }
	    return false;
	}

%}

%union
{
	int value;
	char * str;
}


%token <str> OPERATOR COLON COMPARISON IF ELIF ELSE EQUAL DIGIT IDENTIFIER FLOAT NEWLINE STRING
%type<str> print statement comparison operand assignment
%%


print:
	statement print{
	}
	|
	statement{


    sort(varsLast.begin(), varsLast.end(), [](const variables& a, const variables& b) {
        return a.name < b.name;
    });

		cout<<"void main()\n{\n";

		int intCount = 0;
		int fltCount = 0;
		int strCount = 0;
		int counter = 0;
		for(int i = 0; i<varsLast.size(); i++){
			if(varsLast[i].nameType == "int"){
				intCount++;
			}
			else if(varsLast[i].nameType == "flt"){
				fltCount++;
			}
			else if(varsLast[i].nameType == "str"){
				strCount++;
			}

		}

		if(intCount >0){
			cout<<"\tint ";
			counter = 0;
		}
		for(int i = 0; i<varsLast.size(); i++){
			if(varsLast[i].nameType == "int"){
				counter++;
				if(counter == intCount){
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+";\n";
				}else{
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+",";
				}

			}
		}

		if(fltCount >0){
			cout<<"\tfloat ";
			counter = 0;
		}
		for(int i = 0; i<varsLast.size(); i++){
			if(varsLast[i].nameType == "flt"){
				counter++;
				if(counter == fltCount){
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+";\n";
				}else{
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+",";
				}

			}
		}

		if(strCount >0){
			cout<<"\tstring ";
			counter = 0;
		}
		for(int i = 0; i<varsLast.size(); i++){
			if(varsLast[i].nameType == "str"){
				counter++;
				if(counter == strCount){
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+";\n";
				}else{
					cout<<varsLast[i].name+"_"+varsLast[i].nameType+",";
				}

			}
		}

		cout<<"\n";

		for(int i = 0; i<lines.size(); i++){
			cout<<lines[i];
		}
		if(vec.empty() == 0){
			for(int i = vec.size()-1; i>=0; i--){
				if(vec[i].closed == false){
					for(int j = vec[i].tabCount; j>0; j--){
						cout<<"\t";
					}
					cout<<"}\n";
					vec[i].closed = true;
				}
			}
		}
		cout<<"}\n";
		
	}
	;

statement:
	IF comparison COLON{
		tempTabCounter = tabCounter+1;
		string combined = "";

		if(vec.empty() == 0){
			if(tabCounter <= vec.back().tabCount){
				for(int i = vec.size()-1; i>=0; i--){
					if( (vec[i].tabCount == tabCounter-1 && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else") && vec[i].closed == 0) )
					{
						vec[i].filled = true;
					}
					if(vec[i].closed == false && vec[i].tabCount>=tabCounter){
						for(int j = vec[i].tabCount; j>0; j--){
							combined.append("\t");
						}
						combined.append("}\n");
						vec[i].closed = true;
					}
					if(vec[i].filled == false && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else")){
						cout<<"error in line "<<linenum<<": at least one line should be inside if/elif/else block "<<endl;
						exit(0);
					}
				}
			}
		}


	vec.erase(remove_if(vec.begin(), vec.end(), [](const ifControl& elem) {
	  return elem.closed;
	}), vec.end());

		ifControl temp;
		temp.tabCount = tabCounter;
		temp.closed = false;
		temp.type = "if";
		vec.push_back(temp);

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append(string($1) +"( " + string($2)+" )\n");

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append("{\n");
		$$ = strdup(combined.c_str());
		lines.push_back($$);

		tabCounter = 1;
	}
	|
	ELIF comparison COLON{
		tempTabCounter = tabCounter+1;
		string combined = "";
		bool flag = 0;

		if(vec.empty() == 0){
			if(tabCounter <= vec.back().tabCount){
				for(int i = vec.size()-1; i>=0; i--){
					if( (vec[i].tabCount == tabCounter && (vec[i].type == "if" || vec[i].type == "else if") && vec[i].closed == 0) )
					{
						flag = 1;
					}
					if( (vec[i].tabCount == tabCounter && vec[i].type == "else" && vec[i].closed == 0) )
					{
						cout<<"elif after else in line "<<linenum<<endl;
						exit(0);
					}
					if( (vec[i].tabCount == tabCounter-1 && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else") && vec[i].closed == 0) )
					{
						vec[i].filled = true;
					}
					if(vec[i].closed == false && vec[i].tabCount>=tabCounter){
						for(int j = vec[i].tabCount; j>0; j--){
							combined.append("\t");
						}
						combined.append("}\n");
						vec[i].closed = true;
					}
					if(vec[i].filled == false && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else")){
						cout<<"error in line "<<linenum<<": at least one line should be inside if/elif/else block "<<endl;
						exit(0);
					}
				}
			}
		}

		if(flag==0){
			cout<<"elif without if in line "<<linenum<<endl;
			exit(0);
		}


	vec.erase(remove_if(vec.begin(), vec.end(), [](const ifControl& elem) {
	  return elem.closed;
	}), vec.end());

		ifControl temp;
		temp.tabCount = tabCounter;
		temp.closed = false;
		temp.type = "else if";
		vec.push_back(temp);

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append(string($1) +"( " + string($2)+" )\n");

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append("{\n");
		$$ = strdup(combined.c_str());
		lines.push_back($$);

		tabCounter = 1;
	}
	|
	ELSE COLON{
		tempTabCounter = tabCounter+1;
		string combined = "";
		bool flag = 0;

		if(vec.empty() == 0){
			if(tabCounter <= vec.back().tabCount){
				for(int i = vec.size()-1; i>=0; i--){
					if( (vec[i].tabCount == tabCounter && (vec[i].type == "if" || vec[i].type == "else if") && vec[i].closed == 0) )
					{
						flag = 1;
					}
					if( (vec[i].tabCount == tabCounter-1 && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else") && vec[i].closed == 0) )
					{
						vec[i].filled = true;
					}
					if(vec[i].closed == false && vec[i].tabCount>=tabCounter){
						for(int j = vec[i].tabCount; j>0; j--){
							combined.append("\t");
						}
						combined.append("}\n");
						vec[i].closed = true;
					}
					if(vec[i].filled == false && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else")){
						cout<<"error in line "<<linenum<<": at least one line should be inside if/elif/else block "<<endl;
						exit(0);
					}
				}
			}
		}

		if(flag==0){
			cout<<"else without if in line "<<linenum<<endl;
			exit(0);
		}


	vec.erase(remove_if(vec.begin(), vec.end(), [](const ifControl& elem) {
	  return elem.closed;
	}), vec.end());

		ifControl temp;
		temp.tabCount = tabCounter;
		temp.closed = false;
		temp.type = "else";
		vec.push_back(temp);

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append(string($1) +"\n");

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		combined.append("{\n");
		$$ = strdup(combined.c_str());
		lines.push_back($$);

		tabCounter = 1;
	}
	|
	IDENTIFIER EQUAL assignment{
		string combined = "";

		if(tempTabCounter < tabCounter){
			cout<<"tab inconsistency in line "<<linenum<<endl;
			exit(0);
		}

		if(vec.empty() == 0){
			for(int i = vec.size()-1; i>=0; i--){
				if( (vec[i].tabCount == tabCounter-1 && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else") && vec[i].closed == 0) )
				{
					vec[i].filled = true;
				}

				if(vec[i].closed == false && vec[i].tabCount>=tabCounter){
					for(int j = vec[i].tabCount; j>0; j--){
						combined.append("\t");
					}
					combined.append("}\n");
					if(vec[i].filled == false && (vec[i].type == "if" || vec[i].type == "else if" || vec[i].type == "else")){
						cout<<"error in line "<<linenum<<": at least one line should be inside if/elif/else block "<<endl;
						exit(0);
					}
					vec[i].closed = true;
				}


			}
		}

	vec.erase(remove_if(vec.begin(), vec.end(), [](const ifControl& elem) {
	  return elem.closed;
	}), vec.end());

		string temp = tempVec[0];
		for(int i = 1; i<tempVec.size(); i++){
			if((temp =="flt" && tempVec[i] == "int") || (temp =="int" && tempVec[i] == "flt")){
				temp = "flt";
			}
			else if(tempVec[i] != temp){
				cout<<"type mismatch in line "<<linenum<<endl;
				exit(0);
			}
		}

		if(checkInVector(tabCounter) == 0){
			ifControl temp;
			temp.tabCount = tabCounter;
			temp.closed = true;
			temp.type = "assignment";
			vec.push_back(temp);
		}

		for(int i=0; i<tabCounter; i++){
			combined.append("\t");
		}

		bool check = 0;
		for(int i = 0; i<varsLast.size(); i++){
			if((varsLast[i].name == string($1)) && (varsLast[i].nameType == temp)){
				check = 1;
			}
		}

		if(check == 0){
			variables lastVars;
			lastVars.type = true;
			lastVars.name = string($1);
			lastVars.nameType = temp;
			varsLast.push_back(lastVars);
		}

		bool flag = 0;
		for(int i = 0; i<vars.size(); i++){
			if(vars[i].name == string($1)){
				vars[i].nameType = temp;
				flag = 1;
			}
		}

		if(flag == 0){
			variables temp2;
			temp2.type = true;
			temp2.name = string($1);
			temp2.nameType = temp;
			vars.push_back(temp2);
		}

		combined.append(string($1)+"_"+temp +" " + string($2)+ " "+ string($3)+";\n");
		$$ = strdup(combined.c_str());

		lines.push_back($$);

		tempTabCounter = tabCounter;
		tabCounter = 1;

		tempVec.clear();
	}
	|
	NEWLINE
	;

comparison:
	operand COMPARISON operand{
		string combined = "";
		
		string temp = tempVec[0];
		for(int i = 1; i<tempVec.size(); i++){
			if((temp =="flt" && tempVec[i] == "int") || (temp =="int" && tempVec[i] == "flt")){

			}
			else if(tempVec[i] != temp){
				cout<<"comparison type mismatch in line "<<linenum<<endl;
				exit(0);
			}
		}

		tempVec.clear();

		combined.append(string($1) +" " + string($2)+ " " + string($3));
		$$ = strdup(combined.c_str());
	}
	;

assignment:
	operand OPERATOR assignment{
		string combined = string($1) +" " + string($2)+ " " + string($3);
		$$ = strdup(combined.c_str());
	}
	|
	operand{
		string combined = string($1);
		$$ = strdup(combined.c_str());
	}
	;


operand:
	IDENTIFIER{
		string str ="";
		bool flag = 0;
		for(int i = 0; i<vars.size(); i++){
			if(vars[i].name == string($1)){
				flag = 1;
				str = vars[i].nameType;
				tempVec.push_back(vars[i].nameType);
			}
		}

		if(flag == 0){
			cout<<string($1)+" is not declared at "<<linenum<<endl;
			exit(0);
		}

		string combined = string($1)+"_"+str;
		$$ = strdup(combined.c_str());
	}
	|
	DIGIT{

		tempVec.push_back("int");

		string combined = string($1);
		$$ = strdup(combined.c_str());
	}
	|
	FLOAT{
		tempVec.push_back("flt");
		
		string combined = string($1);
		$$ = strdup(combined.c_str());
	}
	|
	STRING{
		tempVec.push_back("str");
		
		string combined = string($1);
		$$ = strdup(combined.c_str());
	}
	|
	OPERATOR operand
	{
		string combined = string($1)+string($2);
		$$ = strdup(combined.c_str());
	}
	;


%%
void yyerror(string s){
	cerr<<"Error..."<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}