module graph::\data::DDG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;

data DataDependence = EmptyDD() 
					| DataDependence(Graph[int] graph, map[str, set[VariableData]] defs, map[int, set[str]] uses);

alias DataDependences = map[MethodData, DataDependence];
alias VariableData = tuple[str name, int origin];

private alias ReachingDefs = tuple[
			map[int, set[VariableData]] \in, 
			map[int, set[VariableData]] \out
		];

private map[int, set[str]] uses = ();
private map[str, set[VariableData]] definitions = ();
private map[int, set[VariableData]] generators = ();
private map[int, set[VariableData]] kills = ();

private str methodName;

public DataDependence createDDG(MethodData methodData, ControlFlow controlFlow) {
	definitions = ();
	uses = ();
	generators = ();
	kills = ();
	
	methodName = methodData.name;
	
	for(identifier <- environmentDomain(methodData)) {
		kills[identifier] = {};
		generators[identifier] = {};
		
		process(identifier, resolveIdentifier(methodData, identifier));
	}
	
	for(identifier <- generators) {
		for(generated <- generators[identifier]) {
			set[VariableData] killedSet = definitions[generated.name] - generated;
			storeKill(identifier, killedSet);
		} 
	}
	
	ReachingDefs reachingDefs = calculateReachingDefs(methodData, controlFlow);
	DataDependence dataDependence = DataDependence({}, (), ());	

	for(identifier <- uses) {
		for(usedVariable <- uses[identifier]) {
			if(usedVariable notin definitions) {
				continue;
			}
			
			set[VariableData] variableDefs = definitions[usedVariable];

			for(dependency <- reachingDefs.\in[identifier] & variableDefs) {
				dataDependence.graph += { <dependency.origin, identifier> };
			}
		}
	}

	dataDependence.defs = definitions;
	dataDependence.uses = uses;
	
	return dataDependence;
}

private ReachingDefs calculateReachingDefs(MethodData methodData, ControlFlow controlFlow) {
	map[int, set[VariableData]] \in = ();
	map[int, set[VariableData]] \out = ();
	
	bool changed = true;
	
	while(changed) {
		changed = false;
		
		for(identifier <- environmentDomain(methodData)) {
			set[VariableData] oldIn = identifier in \in ? \in[identifier] : {};
			set[VariableData] oldOut = identifier in \out ? \out[identifier] : {};
			
			\in[identifier] = ( 
					{} 
					| it + \out[predecessor] 
					| predecessor <- predecessors(controlFlow.graph, identifier), predecessor in \out
				);
			\out[identifier] = generators[identifier] + (\in[identifier] - kills[identifier]);
			
			if(oldIn != \in[identifier] || oldOut != \out[identifier]) {
				changed = true;
			}
		}
	}
	
	return <\in, \out>;
}

private void storeDefinition(str variableName, int statement) {
	VariableData definition = <variableName, statement>;
	
	if(variableName in definitions) {
		definitions[variableName] += { definition };
	} else {
		definitions[variableName] = { definition };
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
	VariableData generated = <variableName, statement>;
	
	if(statement in generators) {
		generators[statement] += { generated };
	} else {
		generators[statement] = { generated };
	}
}

private void storeKill(int statement, set[VariableData] killSet) {
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
	
	if(callNode: \methodCall(_, name, _) := expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
		}
	}
	
	if(callNode: \methodCall(_, _, name, _):= expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
		}
	}
}

private void checkForDefinition(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeDefinition(name, identifier);
		storeGenerator(identifier, name);
	} 
}

private void process(int identifier, \if(condition, _)) {
	checkForUse(identifier, condition);
	createDataDependenceGraph(identifier, condition);
}

private void process(int identifier, \if(condition, _, _)) {
	checkForUse(identifier, condition);
	createDataDependenceGraph(identifier, condition);
}

private void process(int identifier, \for(initializers, updaters, _)) {
	for(initializer <- initializers) {
		checkForDefinition(identifier, initializer);
		createDataDependenceGraph(identifier, initializer);
	}
	
	for(updater <- updaters) {
		checkForUse(identifier, updater);
		createDataDependenceGraph(identifier, updater);
	}
}

private void process(int identifier, \for(initializers, condition, updaters, _)) {
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

private void process(int identifier, \while(condition, _)) {
	checkForUse(identifier, condition);
	createDataDependenceGraph(identifier, condition);
}

private void process(int identifier, \do(_, condition)) {
	checkForUse(identifier, condition);
	createDataDependenceGraph(identifier, condition);
}

private void process(int identifier, \switch(expression, _)) {
	checkForUse(identifier, expression);
	createDataDependenceGraph(identifier, expression);
}

private void process(int identifier, \try(_, _)) {
	return;
}

private void process(int identifier, \try(_, _, _)) {
	return;
}

private void process(int identifier, \catch(_, _)) {
	return;
}

private void process(int identifier, \return(_)) {
	return;
}

private void process(int identifier, \throw(expression)) {
	checkForUse(identifier, expression);
	createDataDependenceGraph(identifier, expression);
}
		
private void process(int identifier, \expressionStatement(stmt)) {
	createDataDependenceGraph(identifier, stmt);
}
		
private void process(int identifier, Statement stmt) {
	createDataDependenceGraph(identifier, stmt);
}

default void process(int identifier, node treeNode) {
	return;
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
		case \assignment(lhs, operator, rhs): {
			checkForDefinition(identifier, lhs);
			checkForUse(identifier, rhs);
			
			if(operator != "=") {
				checkForUse(identifier, lhs);
			}
			
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
		case \postfix(operand, operator): {
			checkForDefinition(identifier, operand);
			checkForUse(identifier, operand);
		}	
		case \prefix(operator, operand):{
			checkForDefinition(identifier, operand);
			checkForUse(identifier, operand);
		}
	}
}
