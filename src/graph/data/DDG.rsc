module graph::\data::DDG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;
import graph::\data::VariableData;


private alias ReachingDefs = tuple[
			map[int, set[VariableData]] \in, 
			map[int, set[VariableData]] \out
		];


public DataDependence createDDG(MethodData methodData, ControlFlow controlFlow) {
	initializeVariableData(methodData);
	
	for(identifier <- environmentDomain(methodData)) {
		process(identifier, resolveIdentifier(methodData, identifier));
	}
	
	map[int, set[VariableData]] generators = getGenerators();
	map[str, set[VariableData]] definitions = getDefinitions();
	set[VariableData] killedSet;
	
	for(identifier <- generators) {
		for(generated <- generators[identifier]) {
			killedSet = definitions[generated.name] - generated;
			storeKill(identifier, killedSet);
		} 
	}
	
	ReachingDefs reachingDefs = calculateReachingDefs(methodData, controlFlow, generators);
	DataDependence dataDependence = DataDependence({}, (), ());	
	
	map[int, set[str]] uses = getUses();
	set[VariableData] variableDefs;
	
	for(identifier <- uses) {
		for(usedVariable <- uses[identifier]) {
			if(usedVariable notin definitions) {
				continue;
			}
			
			variableDefs = definitions[usedVariable];

			for(dependency <- reachingDefs.\in[identifier] & variableDefs) {
				dataDependence.graph += { <dependency.origin, identifier> };
			}
		}
	}

	dataDependence.defs = definitions;
	dataDependence.uses = uses;
	
	return dataDependence;
}

private ReachingDefs calculateReachingDefs(MethodData methodData, ControlFlow controlFlow, map[int, set[VariableData]] generators) {
	map[int, set[VariableData]] \in = ();
	map[int, set[VariableData]] \out = ();
	map[int, set[VariableData]] kills = getKills();
	
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

private void process(int identifier, \if(condition, _)) {
	checkForUse(identifier, condition);
	processExpression(identifier, condition);
}

private void process(int identifier, \if(condition, _, _)) {
	checkForUse(identifier, condition);
	processExpression(identifier, condition);
}

private void process(int identifier, \for(initializers, updaters, _)) {
	for(initializer <- initializers) {
		checkForDefinition(identifier, initializer);
		processExpression(identifier, initializer);
	}
	
	for(updater <- updaters) {
		checkForUse(identifier, updater);
		processExpression(identifier, updater);
	}
}

private void process(int identifier, \for(initializers, condition, updaters, _)) {
	for(initializer <- initializers) {
		checkForDefinition(identifier, initializer);
		processExpression(identifier, initializer);
	}
	
	checkForUse(identifier, condition);
	processExpression(identifier, condition);
	
	for(updater <- updaters) {
		checkForUse(identifier, updater);
		processExpression(identifier, updater);
	}
}

private void process(int identifier, \while(condition, _)) {
	checkForUse(identifier, condition);
	processExpression(identifier, condition);
}

private void process(int identifier, \do(_, condition)) {
	checkForUse(identifier, condition);
	processExpression(identifier, condition);
}

private void process(int identifier, \switch(expression, _)) {
	checkForUse(identifier, expression);
	processExpression(identifier, expression);
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
	processExpression(identifier, expression);
}
		
private void process(int identifier, \expressionStatement(stmt)) {
	processExpression(identifier, stmt);
}

private void process(int identifier, \methodCall(_, Expression receiver, _, _)) {
	checkForUse(identifier, receiver);
}
		
private void process(int identifier, Statement stmt) {
	processExpression(identifier, stmt);
}

default void process(int identifier, node treeNode) {
	return;
}

private void processExpression(int identifier, node tree) {
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
		case n: \newArray(\type, dimensions, init): {
			throw "Not implemented: <n@src>";
		}
		case \newArray(\type, dimensions): {
			for(dimension <- dimensions) {
				checkForUse(identifier, dimension);
			}
		}
		case n: \arrayInitializer(elements): {
			throw "Not implemented: <n@src>";
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
    	case n: \newObject(expr, \type, args, class): {
			throw "Not implemented: <n@src>";
		}
		case \newObject(Expression expr, Type \type, list[Expression] args): {
			checkForUse(expr);
			
			for(argument <- args) {
    			checkForUse(identifier, argument);
    		}
		}
		case \newObject(Type \type, list[Expression] args, Declaration class): {
			for(argument <- args) {
    			checkForUse(identifier, argument);
    		}
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
    	// TODO: Check if ignoring the name and type thereof makes a difference.
    	case \fieldAccess(isSuper, expression, name): {
			checkForUse(identifier, expression);
		}
		case n: \fieldAccess(isSuper, name): {
			throw "Not implemented: <n@src>";
		}
		// TODO: Check if the right side can also be an expression.
		case \instanceof(leftSide, rightSide): {
			checkForUse(identifier, leftSide);
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
