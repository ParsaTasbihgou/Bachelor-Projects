/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

using std::string

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST + 5]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

CLASS			?i:class
ELSE			?i:else
FI				?i:fi
IF				?i:if
IN				?i:in
INHERITS		?i:inherits
LET				?i:let
LOOP			?i:loop
POOL			?i:pool
THEN			?i:then
WHILE			?i:while
CASE			?i:case
ESAC			?i:esac
OF				?i:of
DARROW          =>
NEW				?i:new
ISVOID			?i:isvoid
TYPEID			[A-Z][a-zA-Z0-9_]*
OBJECTID		[a-z][a-zA-Z0-9_]*
ASSIGN			<-
NOT				?i:not
LE				<=

TRUE			t(?i:rue)
FALSE			f(?i:alse)

INT 			[0-9]+

%x STRING

SYMBOLS			[+/\-*=<.~,;:()@{}]
WHITESPACE		[ \f\r\t\v]+
NEWLINE			\n

SPECIAL_ESCAPE	[btnf]

INVALID			[^a-zA-Z0-9_ \f\r\t\v\n+/\-*=<.~,;:()@{}]

%x COMMENT
%x INLINE_COMMENT

%%

"--" {
	BEGIN(INLINE_COMMENT);
}

<INLINE_COMMENT>[^\n]* {	
}

<INLINE_COMMENT>\n {
	curr_lineno++;
	BEGIN(INITAIL);
}

<INLINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);
	cool_yylval.error_msg = "EOF in comment";
	return ERROR;
}

"(*" {
	BEGIN(COMMENT);
}

<COMMENT>[^\n]* {	
}

<COMMENT>\n {
	curr_lineno++;
}

<COMMENT><<EOF>> {
	BEGIN(INITIAL);
	cool_yylval.error_msg = "EOF in comment";
	return ERROR;
}

<COMMENT>"*)" {
	BEGIN(INITIAL);
}

\" {
	string_buf_ptr = string_buf;
	BEGIN(STRING);
}

<STRING><<EOF>> {
	BEGIN(INITIAL);
	cool_yylval.error_msg = "EOF in string constant";
	return ERROR;
}

<STRING>\n {
	curr_lineno++;
	BEGIN(INITIAL);
	cool_yylval.error_msg = "Unfinished string constant";
	return ERROR;
}

<STRING>\0 {
	BEGIN(INITIAL);
	cool_yylval.error_msg = "Invalid \0 character in string constant";
	return ERROR;
}

<STRING>\" {
	BEGIN(INITAIL);
	*string_buf_ptr = '\0';		/* string table understands null terminated strings. */
	cool_yylval.symbol = stringtable.add_string(string_buf);
	return STR_CONST
}

<STRING>\\{SPECIAL_ESCAPE} {
	if (string_buf_ptr > string_buf + MAX_STR_CONST - 1) {
		BEGIN(INITIAL);
		cool_yylval.error_msg = "String constant buffer overflow";
		return ERROR;
	}
	char escape_char;
	switch (yytext[1]) {
		case 'b':
			escape_char = '\b';
			break;
		case 't':
			escape_char = '\t';
			break;
		case 'n':
			escape_char = '\n';
			break;
		case 'f':
			escape_char = '\f';
			break;
	}
	*string_buf_ptr = escape_char;
	string_buf_ptr++;
}

<STRING>\\(.|\n) {
	if (string_buf_ptr > string_buf + MAX_STR_CONST - 1) {
		BEGIN(INITIAL);
		cool_yylval.error_msg = "String constant buffer overflow";
		return ERROR;
	}
	*string_buf_ptr = yytext[2];
	string_buf_ptr++;
}

<STRING>[^\"\n\0\\]+ {
	int index = 0;
	while (yytext[index]) {
		if (string_buf_ptr > string_buf + MAX_STR_CONST - 1) {
			BEGIN(INITIAL);
			cool_yylval.error_msg = "String constant buffer overflow";
			return ERROR;
		}
		*string_buf_ptr = yytext[index];
		string_buf_ptr++;
		index++;
	}
}

{TRUE} {
	cool_yylval.boolean = true;
	return BOOL_CONST;
}

{FALSE} {
	cool_yylval.boolean = false;
	return BOOL_CONST;
}

{INT} {
	cool_yylval.symbol = inttable.add_string(yytext);
	return INT_CONST;
}

{DARROW} {
	return (DARROW);
}

{LE} {
	return (LE);
}

{ASSIGN} {
	return (ASSIGN);
}

{WHITESPACE} {
}

{NEWLINE} {
	curr_lineno++;
}

{SYMBOLS} {
	return int(yytext[0]);
}

{DARROW} { 
  return (DARROW);
}

{CLASS}	{
	return (CLASS);
}

{ELSE} {
	return (ELSE);
}

{FI} {
	return (FI);
}

{IF} {
	return (IF);
}

{IN} {
	return (IN);
}

{INHERITS}	{
	return (INHERITS);
}

{ISVOID} {
	return (ISVOID);
}

{LET} {
	return (LET);
}

{LOOP} {
	return (LOOP);
}

{POOL} {
	return (POOL);
}

{THEN} {
	return (THEN);
}

{WHILE} {
	return (WHILE);
}

{CASE} {
	return (CASE);
}

{ESAC} {
	return (ESAC);
}

{NEW} {
	return (NEW);
}

{OF} {
	return (OF);
}

{NOT} {
	return (NOT);
}

{INVALID} {
	string error_msg = "Invalid symbol found: " + string(yytext);
	cool_yylval.error_msg = error_msg.c_str();
	return ERROR;
}

%%
int main( int argc, char **argv ) {
	++argv, --argc;  /* skip over program name */
	if (argc > 0)
			yyin = fopen( argv[0], "r" );
	else
			yyin = stdin;

	yylex();
}