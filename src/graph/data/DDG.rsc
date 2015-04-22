module graph::\data::DDG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;

public void createDDG(map[int, node] nodeEnvironment) {
	for(identifier <- domain(nodeEnvironment)) {
		processStatement(identifier, nodeEnvironment[identifier]);
	}
}

private void processStatement(int identifier, node statement) {
	top-down-break visit(statement) {
		case \if(condition, _): {
			createDataDependenceGraph(identifier, condition);
		}
		case \if(condition, _, _): {
			createDataDependenceGraph(identifier, condition);
		}
		case \for(initializers, updaters, _): {
			for(initializer <- initializers) {
				createDataDependenceGraph(identifier, initializer);
			}
			
			for(updater <- updaters) {
				createDataDependenceGraph(identifier, updater);
			}
		}
		case \for(initializers, condition, updaters, _): {
			for(initializer <- initializers) {
				createDataDependenceGraph(identifier, initializer);
			}
			
			createDataDependenceGraph(identifier, condition);
			
			for(updater <- updaters) {
				createDataDependenceGraph(identifier, updater);
			}
		}
		case \while(condition, _): {
			createDataDependenceGraph(identifier, condition);
		}
		case \do(_, condition): {
			createDataDependenceGraph(identifier, condition);
		}
		case \switch(expression, _): {
			createDataDependenceGraph(identifier, expression);
		}
		case \try(_, _): {
			return;
		}
    	case \try(_, _, _): {
    		return;
    	}
    	case \catch(_, _): {
    		return;
    	}
		case \return(expression): {
			createDataDependenceGraph(identifier, expression);
		}
		case \throw(expression): {
			createDataDependenceGraph(identifier, expression);
		}
		case \expressionStatement(stmt) : {
			createDataDependenceGraph(identifier, stmt);
		}
		case Statement stmt: {
			createDataDependenceGraph(identifier, stmt);
		}
	}
}

private void createDataDependenceGraph(int identifier, node tree) {
	visit(tree) {
		case \arrayAccess(array, index): {
			println("Array <array> accessed at <index>");
		}
		case \newArray(\type, dimensions, init): {
			println("Array with <\type> created. Dimensions: <dimensions>. Initialization: <init>.");
		}
		case \newArray(\type, dimensions): {
			println("Array with <\type> created. Dimensions: <dimensions>.");
		}
		case \arrayInitializer(elements): {
			println("An array is initialized with: <elements>.");
		}
		case \assignment(lhs, operator, rhs): {
			println("Statement <identifier> with <operator> assigns to <lhs>.");
		}
		case \cast(\type, expression): {
			println("Statement <identifier> casts <expression> to <\type>.");
		}
		case \newObject(expr, \type, args, class): {
			println(expr);
		}
		case \newObject(expr, \type, args): {
			println(expr);
		}
		case \newObject(\type, args, class): {
			println(args);
		}
    	case \newObject(\type, args): {
    		println(args);
    	}
		case \fieldAccess(isSuper, expression, name): {
			println("Field accessed with <expression> and name <name>.");
		}
		case \fieldAccess(isSuper, name): {
			println("Field <name> accessed.");
		}
    	case \variable(name, extraDimensions): {
			println("Statement <identifier> defines <name>.");
		}
		case \variable(name, extraDimensions, initializer): {
			println("Statement <identifier> defines <name>.");
		}
		case \infix(lhs, _, rhs): {
			if(\simpleName(name) := lhs) {
				println("Statement <identifier> uses <name>.");
			}
			
			if(\simpleName(name) := rhs) {
				println("Statement <identifier> uses <name>.");
			}
		}
		case \postfix(operand, _ ): {
			println("Statement <identifier> uses <operand>.");
		}	
		case \prefix(operator, operand):{
			println("Statement <identifier> uses <operand>.");
		}
		case \methodCall(_, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					println("Statement <identifier> uses <name>.");
				}
			}
		}
		case \methodCall(_, _, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					println("Statement <identifier> uses <name>.");
				}
			}
		}
	}
}

public &T cast(type[&T] tp, value v) throws str {
    if (&T tv := v) {
        return tv;
    } else {
        throw "cast failed";
    }
}