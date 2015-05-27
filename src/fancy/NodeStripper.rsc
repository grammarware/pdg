module fancy::NodeStripper

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;


public map[str, str] stripEnvironment(map[str, node] environment) {
	return ( key : process(environment[key]) | key <- environment);
}

private str process(Declaration declaration) {
	switch(declaration) {
		case \compilationUnit(list[Declaration] imports, list[Declaration] types):
			return "compilationUnit";
    	case \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types):
    		return "compilationUnit <process(package)>";
    	case \enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body):
    		return "enum <name>";
    	case \enumConstant(str name, list[Expression] arguments, Declaration class):
    		return "enumConstant-class <name>";
    	case \enumConstant(str name, list[Expression] arguments):
    		return "enumConstant <name>";
    	case \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):
    		return "class-extends-implements";
    	case \class(list[Declaration] body):
    		return "class";
    	case \interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body):
    		return "interface";
    	case \field(Type \type, list[Expression] fragments):
    		return "field <process(\type)>";
    	case \initializer(Statement initializerBody):
    		return "initializer";
    	case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):
    		return "method-impl <process(\return)>";
    	case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):
    		return "method <process(\return)>";
    	case \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):
    		return "constructor";
    	case \import(str name):
    		return "import";
    	case \package(str name):
    		return "package";
    	case \package(Declaration parentPackage, str name):
    		return "package-parent";
    	case \variables(Type \type, list[Expression] \fragments):
    		return "variables <process(\type)>";
    	case \typeParameter(str name, list[Type] extendsList):
    		return "typeParameter <name>";
    	case \annotationType(str name, list[Declaration] body):
    		return "annotationType <name>";
    	case \annotationTypeMember(Type \type, str name):
    		return "annotationTypeMember <process(\type)>";
    	case \annotationTypeMember(Type \type, str name, Expression defaultBlock):
    		return "annotationTypeMember-default <process(\type)>";
    	case \parameter(Type \type, str name, int extraDimensions):
    		return "parameter <process(\type)>";
    	case \vararg(Type \type, str name):
    		return "vararg <process(\type)>";
	}
}

private str process(Statement statement) {
	switch(statement) {
		case \assert(expression): 
			return "assert";
		case \assert(expression, message):
			return "assert-message";
		case \break():
			return "break";
		case \break(expression):
			return "break " + process(expression);
		case \continue():
			return "continue";
		case \continue(expression):
			return "continue " + process(expression);
		case \do(body, condition):
			return "do";
		case \for(initializers, updaters, body):
			return "for";
		case \for(initializers, condition, updaters, body):
			return "for-condition";
		case \if(condition, thenBranch):
			return "if";
		case \if(condition, thenBranch, elseBranch):
			return "if";
		case \label(str name, Statement body):
			return "label <name>";
		case \return():
			return "return";
		case \return(expression):
			return "return <process(expression)>";
		case \switch(expression, statements): 
			return "switch <process(expression@typ)>";
		case \synchronizedStatement(Expression lock, Statement body):
			return "synchronizedStatement <process(lock)>";
		case \throw(expression):
			return "throw <process(expression@typ)>";
		case \try(body, catchClauses):
			return "try-catch";
		case \try(body, catchClauses, finalClause):
			return "try-catch-final";
		case \catch(exception, body):
			return "catch";
		case \declarationStatement(Declaration declaration):
			return "declarationStatement <process(declaration)>";
		case \while(Expression condition, Statement body):
			return "while";
		case \expressionStatement(stat):
			return "expressionStatement <process(stat)>";
		case \constructorCall(bool isSuper, Expression expr, list[Expression] arguments):
			return "constructorCall <expr@typ>";
    	case \constructorCall(bool isSuper, list[Expression] arguments):
    		return "constructorCall";
		default:
			return "statement";
	}
}

private str process(Expression expr) {
	switch(expr) {
		case \arrayAccess(Expression array, Expression index):
			return "access <process(array)>";
    	case \newArray(Type \type, list[Expression] dimensions, Expression init):
    		return "newArray-init <process(\type)>";
    	case \newArray(Type \type, list[Expression] dimensions):
    		return "newArray <process(\type)>";
    	case \arrayInitializer(list[Expression] elements):
    		return "arrayInitializer";
    	case \assignment(Expression lhs, str operator, Expression rhs):
    		return "assignment <process(lhs@typ)> <operator> <process(rhs@typ)>";
    	case \cast(Type \type, Expression expression):
    		return "cast <process(\type)>";
    	case \characterLiteral(str charValue):
    		return "characterLiteral";
    	case \newObject(Expression expr, Type \type, list[Expression] args, Declaration class):
    		return "newObject <process(\type)>";
    	case \newObject(Expression expr, Type \type, list[Expression] args):
    		return "newObject <process(\type)>";
    	case \newObject(Type \type, list[Expression] args, Declaration class):
    		return "newObject <process(\type)>";
    	case \newObject(Type \type, list[Expression] args):
    		return "newObject <process(\type)>";
    	case \qualifiedName(Expression qualifier, Expression expression):
    		return "qualifiedName";
    	case \conditional(Expression expression, Expression thenBranch, Expression elseBranch):
    		return "conditional <process(expression@typ)>";
    	case \fieldAccess(bool isSuper, Expression expression, str name):
    		return "fieldAccess <process(expression@typ)>";
    	case \fieldAccess(bool isSuper, str name):
    		return "fieldAccess";
    	case \instanceof(Expression leftSide, Type rightSide):
    		return "instanceof <process(rightSide)>";
    	case \methodCall(bool isSuper, str name, list[Expression] arguments):
    		return "methodCall";
    	case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):
    		return "methodCall <process(receiver)>";
    	case \null():
    		return "null";
    	case \number(str numberValue):
    		return "number";
    	case \booleanLiteral(bool boolValue):
    		return "boolean";
    	case \stringLiteral(str stringValue):
    		return "string";
    	case \type(Type \type):
    		return "type <process(\type)>";
    	case \variable(str name, int extraDimensions):
    		return "variable";
    	case \variable(str name, int extraDimensions, Expression \initializer):
    		return "variable-init";
    	case \bracket(Expression expression):
    		return "bracket <process(expression@typ)>";
    	case \this():
    		return "this";
    	case \this(Expression thisExpression):
    		return "this <process(thisExpression@typ)>";
    	case \super():
    		return "super";
    	case \declarationExpression(Declaration decl):
    		return "declarationExpression <process(decl)>";
    	case \infix(Expression lhs, str operator, Expression rhs):
    		return "infix <process(lhs@typ)> <operator> <process(rhs@typ)>";
    	case \postfix(Expression operand, str operator):
    		return "postfix <process(operand@typ)> <operator>";
    	case \prefix(str operator, Expression operand):
    		return "prefix <operator> <process(operand@typ)>";
   		case \simpleName(str name):
   			return "simpleName";
    	case \markerAnnotation(str typeName):
    		return "markerAnnotation <typeName>";
    	case \normalAnnotation(str typeName, list[Expression] memberValuePairs):
    		return "normalAnnotation <typeName>";
    	case \memberValuePair(str name, Expression \value):
    		return "memberValuePair <process(\value@typ)>";       
    	case \singleMemberAnnotation(str typeName, Expression \value):
    		return "singleMemberAnnotation <typeName>";
		default: {
			return "expression";
		}
	}
}

private str process(Type typ) {
	switch(typ) {
		case arrayType(Type \type):
			return "arrayType <process(\type)>";
    	case parameterizedType(Type \type):
    		return "parameterizedType <process(\type)>";
    	case qualifiedType(Type qualifier, Expression simpleName):
    		return "qualifiedType <process(qualifier)>";
    	case simpleType(Expression name):
    		return "simpleType";
    	case unionType(list[Type] types):
    		return "unionType <("" | "<it> <process(t)>" | t <- types)>";
    	case wildcard():
    		return "wildcard";
    	case upperbound(Type \type):
    		return "upperbound <process(\type)>";
    	case lowerbound(Type \type):
    		return "lowerbound <process(\type)>";
    	case \int():
    		return "int";
    	case short():
    		return "short";
    	case long():
    		return "long";
    	case float():
    		return "float";
    	case double():
    		return "double";
    	case char():
    		return "char";
    	case string():
    		return "string";
    	case byte():
    		return "byte";
    	case \void():
    		return "void";
    	case \boolean():
    		return "boolean";
    	default:
    		return "type";
	}
}

private str process(TypeSymbol typ) {
	switch(typ) {
		case \class(_, _):
			return "class"; 
		case \interface(_, _):
			return "interface";
		case \enum(_):
			return "enum";
		case \method(_, _, returnType, _):
			return process(returnType);
		case \constructor(_, _):
			return "constructor";
		case \typeParameter(_, _):
			return "typeParameter"; 
		case \typeArgument(_):
			return "typeArgument";
		case \wildcard(_):
			return "wildcard";
		case \capture(_, _):
			return "capture";
		case \intersection(_):
			return "intersection";
		case \union(_):
			return "union";
		case \object():
			return "object";
		case \int():
			return "int";
		case \float():
			return "float";
		case \double():
			return "double";
		case \short():
			return "short";
		case \boolean():
			return "boolean";
		case \char():
			return "char";
		case \byte():
			return "byte";
		case \long():
			return "long";
		case \void():
			return "void";
		case \null():
			return "null";
		case \array(_, _):
			return "array";
		case \typeVariable(_):
			return "typeVariable";
		case \unresolved():
			return "unresolved";
		default:
			return "typeSymbol";
	}
}