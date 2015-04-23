module graph::\data::DDG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;

map[str, set[int]] definitions = ();

map[int, set[str]] uses = ();
map[int, set[str]] generators = ();

map[int, set[int]] kills = ();

public Graph[int] createDDG(Graph[int] controlFlow, map[int, node] nodeEnvironment) {
	map[int, set[int]] \in = ();
	map[int, set[int]] \out = ();
	
	for(identifier <- domain(nodeEnvironment)) {
		\in[identifier] = {};
		\out[identifier] = {};
		kills[identifier] = {};
		generators[identifier] = {};
		
		processStatement(identifier, nodeEnvironment[identifier]);
	}
	
	for(identifier <- domain(generators)) {
		for(generator <- generators[identifier]) {
			for(definition <- definitions[generator]) {
				storeKill(identifier, definitions[generator] - identifier);
			}
		}
	}
	
	bool changed = true;
	
	while(changed) {
		changed = false;
		
		for(identifier <- domain(nodeEnvironment)) {
			set[int] oldIn = \in[identifier];
			set[int] oldOut = \out[identifier];
			
			for(predecessor <- predecessors(controlFlow, identifier)) {
				\in[identifier] += \out[predecessor];
			}
			
			if(!isEmpty(generators[identifier])) {
				\out[identifier] = { identifier } + (\in[identifier] - kills[identifier]);
			} else {
				\out[identifier] = (\in[identifier] - kills[identifier]);
			}
			
			if(oldIn != \in[identifier] || oldOut != \out[identifier]) {
				changed = true;
			}
		}
	}
		
	Graph[int] dataDependenceGraph = {};
	
	for(identifier <- uses) {
		for(usedVariable <- uses[identifier]) {
			set[int] variableDefs = definitions[usedVariable];
			for(dependency <- \in[identifier] & variableDefs) {
				dataDependenceGraph += <dependency, identifier>;
			}
		}
	}
	
	println("Uses: <uses>");
	println("Kills: <kills>");
	println("Generators: <generators>");
	println("Definitions: <definitions>");
	println("");
	println("In: <\in>");
	println("Out: <\out>");
	println("");
	println("Data dependences: <dataDependenceGraph>");
	
	return dataDependenceGraph;
}

private void storeDefinition(str variableName, int statement) {
	if(variableName in definitions) {
		definitions[variableName] += { statement };
	} else {
		definitions[variableName] = { statement };
	}
}

private void storeUse(int statement, str variableName) {
	if(statement in uses) {
		uses[statement] += { variableName };
	} else {
		uses[statement] = { variableName };
	}
}

private void storeGenerator(int statement, str variableName) {
	if(statement in generators) {
		generators[statement] += { variableName };
	} else {
		generators[statement] = { variableName };
	}
}

private void storeKill(int statement, set[int] killSet) {
	if(statement in kills) {
		kills[statement] += killSet;
	} else {
		kills[statement] = killSet;
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
			throw "Array access not implemented. <array>, <index>.";
		}
		case \newArray(\type, dimensions, init): {
			throw "Array with <\type> created. Dimensions: <dimensions>. Initialization: <init>.";
		}
		case \newArray(\type, dimensions): {
			throw "Array with <\type> created. Dimensions: <dimensions>.";
		}
		case \arrayInitializer(elements): {
			throw "An array is initialized with: <elements>.";
		}
		case \assignment(lhs, operator, rhs): {
			if(\simpleName(name) := lhs) {
				storeDefinition(name, identifier);
				storeGenerator(identifier, name);
			}
			
			if(\simpleName(name) := rhs) {
				storeUse(identifier, name);
			}
		}
		case \cast(\type, expression): {
			if(\simpleName(name) := expression) {
				storeUse(identifier, name);
			}
		}
		case \newObject(expr, \type, args, class): {
			throw "Not implemented newObject(Expression, Type, Arguments, Class). <expr>, <\type>, <args>, <class>";
		}
		case \newObject(expr, \type, args): {
			throw "Not implemented newObject(Expression, Type, Arguments). <expr>, <\type>, <args>";
		}
		case \newObject(\type, args, class): {
			throw "Not implemented newObject(Type, Arguments, Class). <\type>, <args>, <class>";
		}
    	case \newObject(\type, args): {
    		for(argument <- args) {
    			if(\simpleName(name) := argument) {
    				storeUse(identifier, name);
    			} 
    		}
    	}
    	case \qualifiedName(qualifier, expression): {
    		println("Not implemented qualifiedName(<qualifier>, <expression>).");
    	}
    	case \conditional(expression, thenBranch, elseBranch): {
    		if(\simpleName(name) := expression) {
    			storeUse(identifier, name);
    		}
    		
    		if(\simpleName(name) := thenBranch) {
    			storeUse(identifier, name);
    		}
    		
    		if(\simpleName(name) := elseBranch) {
    			storeUse(identifier, name);
    		}
    	}
		case \fieldAccess(isSuper, expression, name): {
			throw "Not implemented fieldAccess(<isSuper>, <expression>, <name>)";
		}
		case \fieldAccess(isSuper, name): {
			throw "Not implemented fieldAccess(<isSuper>, <name>)";
		}
		case \instanceof(leftSide, rightSide): {
			throw "Not implemented instanceof(<leftSide>, <rightSide>)";
		}
		case \methodCall(_, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					storeUse(identifier, name);
				}
			}
		}
		case \methodCall(_, _, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					storeUse(identifier, name);
				}
			}
		}
    	case \variable(name, extraDimensions): {
    		storeDefinition(name, identifier);
			storeGenerator(identifier, name);
		}
		case \variable(name, extraDimensions, initializer): {
			storeDefinition(name, identifier);
			storeGenerator(identifier, name);
		}
		case \bracket(expression): {
			if(\simpleName(name) := expression) {
				storeUse(identifier, name);
			}
		}
		case \this(thisExpression): {
			throw "Not implemented this(<thisExpression>)";
		}
		case \infix(lhs, _, rhs): {
			if(\simpleName(name) := lhs) {
				storeUse(identifier, name);
			}
			
			if(\simpleName(name) := rhs) {
				storeUse(identifier, name);
			}
		}
		case \postfix(operand, _ ): {
			if(\simpleName(name) := operand) {
				storeUse(identifier, name);
			}
		}	
		case \prefix(_, operand):{
			if(\simpleName(name) := operand) {
				storeUse(identifier, name);
			}
		}
		case \methodCall(_, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					storeUse(identifier, name);
				}
			}
		}
		case \methodCall(_, _, _, arguments): {
			for(argument <- arguments) {
				if(\simpleName(name) := argument) {
					storeUse(identifier, name);
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