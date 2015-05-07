module graph::\data::DDG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;

private map[str, set[int]] definitions = ();

private map[int, set[str]] uses = ();
private map[int, set[str]] generators = ();

private map[int, set[int]] kills = ();

private str methodName;

public DataDependence createDDG(MethodData methodData, ControlFlow controlFlow) {
	map[int, set[int]] \in = ();
	map[int, set[int]] \out = ();
	
	definitions = ();
	uses = ();
	generators = ();
	kills = ();
	
	methodName = methodData.name;
	
	for(identifier <- environmentDomain(methodData)) {
		\in[identifier] = {};
		\out[identifier] = {};
		kills[identifier] = {};
		generators[identifier] = {};
		
		processStatement(identifier, resolveIdentifier(methodData, identifier));
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
		
		for(identifier <- environmentDomain(methodData)) {
			set[int] oldIn = \in[identifier];
			set[int] oldOut = \out[identifier];
			
			for(predecessor <- predecessors(controlFlow.graph, identifier)) {
				\in[identifier] += \out[predecessor];
			}
			
			if(!isEmpty(generators[identifier])) {
				\out[identifier] = { identifier } + (\in[identifier] - kills[identifier]);
			} else {
				\out[identifier] = \in[identifier] - kills[identifier];
			}
			
			if(oldIn != \in[identifier] || oldOut != \out[identifier]) {
				changed = true;
			}
		}
	}
	
	DataDependence dataDependence = DataDependence({}, (), (), (), ());	

	for(identifier <- uses) {
		for(usedVariable <- uses[identifier]) {
			if(usedVariable notin definitions) {
				continue;
			}
			
			set[int] variableDefs = definitions[usedVariable];
			for(dependency <- \in[identifier] & variableDefs) {
				dataDependence.graph += { <dependency, identifier> };
			}
		}
	}
	
	dataDependence.\in = \in;
	dataDependence.\out = \out;
	dataDependence.defs = definitions;
	dataDependence.uses = uses;
	
	return dataDependence;
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

private void checkForUse(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeUse(identifier, name);
	}
	
	if(callNode: \methodCall(_, name, arguments) := expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return");
		}
	}
	
	if(callNode: \methodCall(_, _, name, arguments):= expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return");
		}
	}
}

private void checkForDefinition(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeDefinition(name, identifier);
		storeGenerator(identifier, name);
	} 
}

private void processStatement(int identifier, node statement) {
	top-down-break visit(statement) {
		case \if(condition, _): {
			checkForUse(identifier, condition);
			createDataDependenceGraph(identifier, condition);
		}
		case \if(condition, _, _): {
			checkForUse(identifier, condition);
			createDataDependenceGraph(identifier, condition);
		}
		case \for(initializers, updaters, _): {
			for(initializer <- initializers) {
				checkForDefinition(identifier, initializer);
				createDataDependenceGraph(identifier, initializer);
			}
			
			for(updater <- updaters) {
				checkForUse(identifier, updater);
				createDataDependenceGraph(identifier, updater);
			}
		}
		case \for(initializers, condition, updaters, _): {
			for(initializer <- initializers) {
				checkForDefinition(identifier, initializer);
				createDataDependenceGraph(identifier, initializer);
			}
			
			checkForUse(identifier, condition);
			createDataDependenceGraph(identifier, condition);
			
			for(updater <- updaters) {
				checkForUse(identifier, updater);
				createDataDependenceGraph(identifier, updater);
			}
		}
		case \while(condition, _): {
			checkForUse(identifier, condition);
			createDataDependenceGraph(identifier, condition);
		}
		case \do(_, condition): {
			checkForUse(identifier, condition);
			createDataDependenceGraph(identifier, condition);
		}
		case \switch(expression, _): {
			checkForUse(identifier, expression);
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
			return;
		}
		case \throw(expression): {
			checkForUse(identifier, expression);
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
			checkForUse(identifier, array);
			checkForUse(identifier, index);
			
			if(\simpleName(name) := array) {
				if(\simpleName(_) := index) {
					storeUse(identifier, "<name>[variable]");
				}
				
				if(\number(numberValue) := index) {
					storeUse(identifier, "<name>[<numberValue>]");
				}
			}
		}
		case \newArray(\type, dimensions, init): {
			throw "Array with <\type> created. Dimensions: <dimensions>. Initialization: <init>.";
		}
		case \newArray(\type, dimensions): {
			for(dimension <- dimensions) {
				checkForUse(identifier, dimension);
			}
		}
		case \arrayInitializer(elements): {
			throw "An array is initialized with: <elements>.";
		}
		case \assignment(lhs, _, rhs): {
			checkForDefinition(identifier, lhs);
			checkForUse(identifier, rhs);
			
			if(\arrayAccess(\simpleName(name), index) := lhs) {
				if(\simpleName(_) := index) {
					storeDefinition("<name>[variable]", identifier);
					storeGenerator(identifier, "<name>[variable]");
				}
				
				if(\number(numberValue) := index) {
					storeDefinition("<name>[<numberValue>]", identifier);
					storeGenerator(identifier, "<name>[<numberValue>]");
				}
			}
		}
		case \cast(_, expression): {
			checkForUse(identifier, expression);
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
    			checkForUse(identifier, argument);
    		}
    	}
    	case \conditional(expression, thenBranch, elseBranch): {
    		checkForUse(identifier, expression);
    		checkForUse(identifier, thenBranch);
    		checkForUse(identifier, elseBranch);
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
    	case \variable(name, extraDimensions): {
    		storeDefinition(name, identifier);
			storeGenerator(identifier, name);
		}
		case \variable(name, extraDimensions, initializer): {
			storeDefinition(name, identifier);
			storeGenerator(identifier, name);
			
			checkForUse(identifier, initializer);
		}
		case \bracket(expression): {
			checkForUse(identifier, expression);
		}
		case \this(thisExpression): {
			throw "Not implemented this(<thisExpression>)";
		}
		case \infix(lhs, _, rhs): {
			checkForUse(identifier, lhs);
			checkForUse(identifier, rhs);
		}
		case \postfix(operand, _ ): {
			checkForUse(identifier, operand);
		}	
		case \prefix(_, operand):{
			checkForUse(identifier, operand);
		}
	}
}
