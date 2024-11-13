package cup.example;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.Symbol;
import java.lang.*;
import java.io.InputStreamReader;

%%

%class Lexer
%implements sym
%public
%unicode
%line
%column
%cup
%char
%{
	

    public Lexer(ComplexSymbolFactory sf, java.io.InputStream is){
		this(is);
        symbolFactory = sf;
    }
	public Lexer(ComplexSymbolFactory sf, java.io.Reader reader){
		this(reader);
        symbolFactory = sf;
    }
    
    private StringBuffer sb;
    private ComplexSymbolFactory symbolFactory;
    private int csline,cscolumn;

    public Symbol symbol(String name, int code){
		return symbolFactory.newSymbol(name, code,
						new Location(yyline+1,yycolumn+1, yychar), // -yylength()
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength())
				);
    }
    public Symbol symbol(String name, int code, String lexem){
	return symbolFactory.newSymbol(name, code, 
						new Location(yyline+1, yycolumn +1, yychar), 
						new Location(yyline+1,yycolumn+yylength(), yychar+yylength()), lexem);
    }
    
    protected void emit_warning(String message){
    	System.out.println("scanner warning: " + message + " at : 2 "+ 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
    
    protected void emit_error(String message){
    	System.out.println("scanner error: " + message + " at : 2" + 
    			(yyline+1) + " " + (yycolumn+1) + " " + yychar);
    }
%}

Newline     = \r | \n | \r\n
Whitespace  = [ \t\f] | {Newline}
Number      = [0-9]+
Letter 		= [a-zA-Z]
Identifier 	= ({Letter}|_)({Number}|{Letter}|_)*
Integer  	= {Number}
StringLit   = "\""( [^\"\\\n] | \\[tn\"'\\] )*"\""



/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}
TraditionalComment = "/*" {CommentContent} \*+ "/"
EndOfLineComment = "//" [^\r\n]* {Newline}
CommentContent = ( [^*] | \*+[^*/] )*

ident = ([:jletter:] | "_" ) ([:jletterdigit:] | [:jletter:] | "_" )*


%eofval{
    return symbolFactory.newSymbol("EOF",sym.EOF);
%eofval}

%state CODESEG

%%  

<YYINITIAL> {

  {Whitespace} {   }
  {Number}     { return symbolFactory.newSymbol("NUMBER", NUMBER, Integer.parseInt(yytext())); }  
  “\””         { return symbolFactory.newSymbol("DOUBLEQUOTE", DOUBLEQUOTE); }                         }
  ";"          { return symbolFactory.newSymbol("SEMI", SEMI); }
  "n"          { return symbolFactory.newSymbol("UMINUS", UMINUS); }
  "("          { return symbolFactory.newSymbol("LPAREN", LPAREN); }
  ")"          { return symbolFactory.newSymbol("RPAREN", RPAREN); }
  "["          { return symbolFactory.newSymbol("LSQUARE", LSQUARE); }
  "]"          { return symbolFactory.newSymbol("RSQUARE", RSQUARE); }
  "{"          { return symbolFactory.newSymbol("LBRACKET", LBRACKET); }
  "}"          { return symbolFactory.newSymbol("RBRACKET", RBRACKET); }
  ","          { return symbolFactory.newSymbol("COMMA", COMMA); }
  "="          { return symbolFactory.newSymbol("EQUAL", EQUAL); }
  "!"          { return symbolFactory.newSymbol("NOT", NOT); }
  "||"         { return symbolFactory.newSymbol("OROR", OROR); }
  "&&"         { return symbolFactory.newSymbol("ANDAND", ANDAND); }
  "=="         { return symbolFactory.newSymbol("EQUALEQUAL", EQUALEQUAL); }
  "!="         { return symbolFactory.newSymbol("DIFFERENT", DIFFERENT); }
  "<="         { return symbolFactory.newSymbol("LESSEQUAL", LESSEQUAL); }
  ">="         { return symbolFactory.newSymbol("BIGGEREQUAL", BIGGEREQUAL); }
  "<<"         { return symbolFactory.newSymbol("LSHIFT", LSHIFT); }
  ">>"         { return symbolFactory.newSymbol("RSHIFT", RSHIFT); }
  ">"          { return symbolFactory.newSymbol("BIGGER", BIGGER); }
  "<"          { return symbolFactory.newSymbol("LESS", LESS); }
  
   //Arithmetic Operators
  "+"          { return symbolFactory.newSymbol("PLUS", PLUS); }
  "-"          { return symbolFactory.newSymbol("MINUS", MINUS); } 
  "*"          { return symbolFactory.newSymbol("TIMES", TIMES); }
  "/"          { return symbolFactory.newSymbol("DIV", DIV); }
  
  //KEYWORDS
 "int"          { return symbolFactory.newSymbol("INT", INT); }
 "bool"         { return symbolFactory.newSymbol("BOOL", BOOL); }
 "void"         { return symbolFactory.newSymbol("VOID", VOID); }
 "true"         { return symbolFactory.newSymbol("TRUE", TRUE); }
 "false"        { return symbolFactory.newSymbol("FALSE", FALSE); }
 "if"           { return symbolFactory.newSymbol("IF", IF); }
 "else"         { return symbolFactory.newSymbol("ELSE", ELSE); }
 "while"        { return symbolFactory.newSymbol("WHILE", WHILE); }
 "return"       { return symbolFactory.newSymbol("RETURN", RETURN); }
 "cin"          { return symbolFactory.newSymbol("CIN", CIN); }
 "cout"         { return symbolFactory.newSymbol("COUT", COUT); }
 "read"         { return symbolFactory.newSymbol("READ", READ); }
 "write"        { return symbolFactory.newSymbol("WRITE", WRITE); }
  
  {Identifier} { return symbolFactory.newSymbol("ID", ID); }
  {StringLit}  { return symbolFactory.newSymbol("STRING_LITERAL", STRING_LITERAL, yytext()); }



// error fallback
.|\n          { emit_warning("Unrecognized character '" +yytext()+"' -- ignored"); }
