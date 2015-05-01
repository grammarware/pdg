module graph::control::flow::CFG

import Prelude;
import List;

import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;
import graph::control::flow::JumpEnvironment;

// A counter to identify nodes.
private int nodeIdentifier = 0;

private set[loc] calledMethods = {};

// Storage for all the visited nodes with their identifier as key.
private map[int, node] nodeEnvironment = ();

private int getIdentifier() {
	int identifier = nodeIdentifier;
	
	nodeIdentifier += 1;
	
	return identifier;
}

public MethodData createCFG(MethodData methodData) {
	calledMethods = {};
	nodeEnvironment = ();
	nodeIdentifier = 0;
	
	ControlFlow controlFlow = createControlFlow(methodData.abstractTree);
	controlFlow.exitNodes += getReturnNodes();
	controlFlow.exitNodes += getThrowNodes();
	
	if(\method(_, name, parameters, _, _) := methodData.abstractTree) {
		println(name);
	}
	
	methodData.calledMethods = calledMethods;
	methodData.nodeEnvironment = nodeEnvironment;
	methodData.controlFlow = controlFlow;
	
	resetJumps();
	
	return methodData;
}

private int storeNode(node treeNode) {
	int identifier = getIdentifier();

	nodeEnvironment[identifier] = treeNode;
	
	return identifier;
}

private ControlFlow createControlFlow(node tree) {
	ControlFlow controlFlow;
	int identifier;
	
	top-down-break visit(tree) {
		case blockNode: \block(body): {
			controlFlow = processBlock(body); 
		}
		case ifNode: \if(condition, thenBranch): {
			identifier = storeNode(ifNode);
			controlFlow = processIf(identifier, condition, thenBranch);
		}
		case ifNode: \if(condition, thenBranch, elseBranch): {
			identifier = storeNode(ifNode);
			controlFlow = processIfElse(identifier, condition, thenBranch, elseBranch);
		}
		case forNode: \for(_, _, _): {
			identifier = storeNode(forNode);
			controlFlow = processFor(identifier, forNode);
		}
		case forNode: \for(_, _, _, _): {
			identifier = storeNode(forNode);
			controlFlow = processFor(identifier, forNode);
		}
		case whileNode: \while(condition, body): {
			identifier = storeNode(whileNode);
			controlFlow = processWhile(identifier, condition, body);
		}
		case doNode: \do(body, condition): {
			identifier = storeNode(doNode);
			controlFlow = processDoWhile(identifier, body, condition);
		}
		case switchNode: \switch(expression, statements): {
			identifier = storeNode(switchNode);
			controlFlow = processSwitch(identifier, expression, statements);
		}
		case tryNode: \try(body, catchClauses): {
			identifier = storeNode(tryNode);
			controlFlow = processTry(identifier, body, catchClauses);
		}
    	case tryNode: \try(body, catchClauses, finalClause): {
    		identifier = storeNode(tryNode);
    		controlFlow = processTry(identifier, body, catchClauses, finalClause);
    	}
    	case catchNode: \catch(exception, body): {
    		identifier = storeNode(catchNode);
    		controlFlow = processCatch(identifier, exception, body);
    	}
		case breakNode: \break(): {
			identifier = storeNode(breakNode);
			controlFlow = processBreak(identifier, breakNode);
		}
		case breakNode: \break(_): {
			identifier = storeNode(breakNode);
			controlFlow = processBreak(identifier, breakNode);
		}
		case continueNode: \continue(): {
			identifier = storeNode(continueNode);
			controlFlow = processContinue(identifier, continueNode);
		}
		case continueNode: \continue(_): {
			identifier = storeNode(continueNode);
			controlFlow = processContinue(identifier, continueNode);
		}
		case returnNode: \return(): {
			identifier = storeNode(returnNode);
			controlFlow = processReturn(identifier, returnNode);
		}
		case returnNode: \return(expression): {
			list[ControlFlow] callsites = registerMethodCalls(expression);
			
			identifier = storeNode(returnNode);
			controlFlow = connectControlFlows(callsites + processReturn(identifier, returnNode));
		}
		case throwNode: \throw(_): {
			identifier = storeNode(throwNode);
			controlFlow = processThrow(identifier, throwNode);
		}
		case statementNode: \expressionStatement(Expression stmt): {
			list[ControlFlow] callsites = registerMethodCalls(stmt);
			
			if(!isMethodCall(stmt)) {
				identifier = storeNode(statementNode);
				controlFlow = connectControlFlows(callsites + processStatement(identifier, statementNode));
			} else {
				controlFlow = connectControlFlows(callsites);
			}
		}
		case Statement statement: {
			identifier = storeNode(statement);
			controlFlow = processStatement(identifier, statement);
		}
	}
	
	return controlFlow;
}

private bool isMethodCall(Expression expression) {
	switch(expression) {
		case \methodCall(_, _, _): {
			return true;
		}
    	case \methodCall(_, _, _, _): {
    		return true;
    	}
	}
	
	return false;
}

private list[ControlFlow] registerMethodCalls(Expression expression) {
	list[ControlFlow] callsites = [];
	int identifier;
	
	visit(expression) {
		case callNode: \methodCall(isSuper, name, arguments): {
			identifier = storeNode(callNode);
			
			callsites += ControlFlow({}, identifier, {identifier});
			calledMethods += callNode@decl;
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		identifier = storeNode(callNode);
			
			callsites += ControlFlow({}, identifier, {identifier});
			calledMethods += callNode@decl;
    	}
	}
	
	return callsites;
}

private ControlFlow connectControlFlows(list[ControlFlow] controlFlows) {
	tuple[ControlFlow popped, list[ControlFlow] rest] popTuple = pop(controlFlows);
	
	ControlFlow first = popTuple.popped;
	ControlFlow connectedControlFlow = first;
	
	if(size(popTuple.rest) >= 2) {
		popTuple = pop(popTuple.rest);
		ControlFlow second = popTuple.popped;
		
		connectedControlFlow.graph = first.graph
							+ second.graph 
							+ createConnectionEdges(first, second);
	
		ControlFlow successorGraph = connectControlFlows(popTuple.rest);
		connectedControlFlow.graph = connectedControlFlow.graph
							+ successorGraph.graph 
							+ createConnectionEdges(second, successorGraph);
		connectedControlFlow.exitNodes = successorGraph.exitNodes;
	} else if(size(popTuple.rest) >= 1) {
		popTuple = pop(popTuple.rest);
		connectedControlFlow.graph = connectedControlFlow.graph
							+ popTuple.popped.graph
							+ createConnectionEdges(connectedControlFlow, popTuple.popped);
		connectedControlFlow.exitNodes = popTuple.popped.exitNodes;
	}
	
	return connectedControlFlow;
}

private Graph[int] createConnectionEdges(ControlFlow first, ControlFlow second) {
	return first.exitNodes * {second.entryNode};
}

private ControlFlow processBlock(list[Statement] body) {
	list[ControlFlow] controlFlows = [];
	
	for(statement <- body) {
		controlFlows += createControlFlow(statement);
	}
	
	return connectControlFlows(controlFlows);
}

private ControlFlow createConditionalBranchFlow(Statement branch) {
	if(\block(body) := branch) {
		return processBlock(body);
	}
	
	return createControlFlow(branch);
}

private ControlFlow processIf(int identifier, Expression condition, Statement thenBranch) {
	ControlFlow ifFlow = ControlFlow({}, 0, {});
	
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	ControlFlow thenFlow = createConditionalBranchFlow(thenBranch);
	
	ifFlow.graph += thenFlow.graph + createConnectionEdges(ifFlow, thenFlow);
	ifFlow.exitNodes += thenFlow.exitNodes;
	
	return ifFlow;
}

private ControlFlow processIfElse(int identifier, Expression condition, Statement thenBranch, Statement elseBranch) {
	ControlFlow ifElseFlow = ControlFlow({}, 0, {});
	
	ifElseFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifElseFlow.exitNodes += {identifier};
	
	ControlFlow thenFlow = createConditionalBranchFlow(thenBranch);
	
	ifElseFlow.graph += thenFlow.graph + createConnectionEdges(ifElseFlow, thenFlow);
	
	ControlFlow elseFlow = createConditionalBranchFlow(elseBranch);
	
	ifElseFlow.graph += elseFlow.graph + createConnectionEdges(ifElseFlow, elseFlow);
	ifElseFlow.exitNodes += elseFlow.exitNodes + thenFlow.exitNodes;
	ifElseFlow.exitNodes -= {identifier};
	
	return ifElseFlow;
}

private ControlFlow processFor(int identifier, Statement forNode) {
	ControlFlow forFlow = ControlFlow({}, 0, {});
	
	forFlow.entryNode = identifier;
	forFlow.exitNodes += {identifier};
	
	ControlFlow bodyFlow;
	
	scopeDown();
	
	if(\for(_, _, _,body) := forNode) {
		bodyFlow = createControlFlow(body);
	} else if(\for(_, _, body) := forNode) {
		bodyFlow = createControlFlow(body);
	}
	
	bodyFlow.exitNodes += getContinueNodes();
	
	forFlow.graph += bodyFlow.graph;
	forFlow.graph += createConnectionEdges(forFlow, bodyFlow);
	forFlow.graph += createConnectionEdges(bodyFlow, forFlow);
		
	forFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return forFlow;
}

private ControlFlow processWhile(int identifier, Expression condition, Statement body) {
	ControlFlow whileFlow = ControlFlow({}, 0, {});
	
	whileFlow.entryNode = identifier;
	whileFlow.exitNodes += {identifier};
	
	scopeDown();
	
	ControlFlow bodyFlow = createControlFlow(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	whileFlow.graph += bodyFlow.graph;
	whileFlow.graph += createConnectionEdges(bodyFlow, whileFlow);
	whileFlow.graph += createConnectionEdges(whileFlow, bodyFlow);
	
	whileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return whileFlow;
}

private ControlFlow processDoWhile(int identifier, Statement body, Expression condition) {
	ControlFlow doWhileFlow = ControlFlow({}, 0, {});
	
	scopeDown();
	
	// Process the body first, as it is always executed once.
	ControlFlow bodyFlow = createControlFlow(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	doWhileFlow.entryNode = identifier;
	doWhileFlow.exitNodes += {identifier};
	
	doWhileFlow.graph += bodyFlow.graph;
	doWhileFlow.graph += createConnectionEdges(bodyFlow, doWhileFlow);
	
	doWhileFlow.entryNode = bodyFlow.entryNode;
	doWhileFlow.graph += createConnectionEdges(doWhileFlow, bodyFlow);
	
	doWhileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return doWhileFlow;
}

private list[ControlFlow] processCases(list[Statement] statements) {
	ControlFlow caseFlow = ControlFlow({}, 0, {});
	
	tuple[node popped, list[node] remainder] popTuple = pop(statements);
	ControlFlow caseNode = createControlFlow(popTuple.popped);
	statements = popTuple.remainder;
	
	caseFlow.entryNode = caseNode.entryNode;
	caseFlow.exitNodes = caseNode.exitNodes;
	
	bool isNotDefault(node treeNode) = !(\defaultCase() := treeNode);
	bool isNotCase(node treeNode) = (!(\case(_) := treeNode) && isNotDefault(treeNode));
	
	list[node] caseBody = takeWhile(statements, isNotCase);
	
	ControlFlow caseBodyFlow = processBlock(caseBody);
	statements -= caseBody;
	
	caseFlow.graph = caseBodyFlow.graph + createConnectionEdges(caseFlow, caseBodyFlow);
	caseFlow.exitNodes = caseBodyFlow.exitNodes;
	
	list[ControlFlow] caseFlows = [caseFlow];
	
	if(size(statements) >= 1) {
		caseFlows += processCases(statements); 
	}
	
	return caseFlows;
}

private ControlFlow processSwitch(int identifier, Expression expression, list[Statement] statements) {
	ControlFlow switchFlow = ControlFlow({}, 0, {});
	
	switchFlow.entryNode = identifier;
	switchFlow.exitNodes = {identifier};
	
	list[ControlFlow] caseFlows = processCases(statements);
	set[int] finalExitNodes = {};
	
	for(caseFlow <- caseFlows) {
		switchFlow.graph += caseFlow.graph + createConnectionEdges(switchFlow, caseFlow);
		switchFlow.exitNodes += caseFlow.exitNodes;
		
		// Previous loop's exit nodes are now bound. Remove them.
		switchFlow.exitNodes -= finalExitNodes;
		
		finalExitNodes = caseFlow.exitNodes;
	}
	
	switchFlow.exitNodes = finalExitNodes + getBreakNodes();
	
	return switchFlow;
}

private bool isTryExit(int identifier) {
	switch(nodeEnvironment[identifier]) {	
		case \block(body): {
			return false;
		}
		case \if(condition, thenBranch): {
			return true;
		}
		case \if(condition, thenBranch, elseBranch): {
			return true;
		}
		case \for(_, _, _): {
			return true;
		}
		case \for(_, _, _, _): {
			return true;
		}
		case \while(condition, body): {
			return true;
		}
		case \do(body, condition): {
			return true;
		}
		case \switch(expression, statements): {
			return false;
		}
		case \try(body, catchClauses): {
			return false;
		}
    	case \try(body, catchClauses, finalClause): {
    		return false;
    	}
    	case \catch(exception, body): {
    		return false;
    	}
		case \break(): {
			return false;
		}
		case \break(_): {
			return false;
		}
		case \continue(): {
			return false;
		}
		case \continue(_): {
			return false;
		}
		case \return(): {
			return false;
		}
		case \return(_): {
			return false;
		}
		case \throw(_): {
			return true;
		}
		case \methodCall(_, _, _): {
			return true;
		}
    	case \methodCall(_, _, _, _): {
    		return true;
    	}
		case Statement statement: {
			return true;
		}
	}

	return false;
}

private ControlFlow processTry(int identifier, Statement body, list[Statement] catchClauses) {
	ControlFlow tryFlow = ControlFlow({}, 0, {});
	
	tryFlow.entryNode = identifier;
	tryFlow.exitNodes = { identifier };
	
	ControlFlow bodyFlow = createControlFlow(body);
	tryFlow.graph = bodyFlow.graph + createConnectionEdges(tryFlow, bodyFlow);
	tryFlow.exitNodes = bodyFlow.exitNodes;

	set[int] potentialThrows = {};
	
	scopeDown();

	for(treeNode <- carrier(tryFlow.graph)) {
		if(isTryExit(treeNode)) {
			potentialThrows += treeNode;
		}
	}
	
	potentialThrows += getThrowNodes();
	
	scopeUp();
	
	list[ControlFlow] catchFlows = [];
	
	for(catchClause <- catchClauses) {
		catchFlows += createControlFlow(catchClause);
	}
	
	for(catchFlow <- catchFlows) {
		tryFlow.graph += potentialThrows * {catchFlow.entryNode};
		tryFlow.graph += catchFlow.graph;
		tryFlow.exitNodes += catchFlow.exitNodes;
	}
	
	return tryFlow;
}

private ControlFlow processTry(int identifier, Statement body, list[Statement] catchClauses, Statement finallyClause) {
	ControlFlow tryFlow = processTry(identifier, body, catchClauses);
	ControlFlow finallyFlow = createControlFlow(finallyClause);
	
	tryFlow.graph += createConnectionEdges(tryFlow, finallyFlow);
	tryFlow.exitNodes = finallyFlow.exitNodes;	
	
	return tryFlow;
}

private ControlFlow processCatch(int identifier, Declaration exception, Statement body) {
	ControlFlow catchFlow = ControlFlow({}, 0, {});
	catchFlow.entryNode = identifier;
	catchFlow.exitNodes = {identifier};
	
	scopeDown();
	
	ControlFlow bodyFlow = createControlFlow(body);
	
	scopeUp();
	
	catchFlow.graph = bodyFlow.graph + createConnectionEdges(catchFlow, bodyFlow);
	catchFlow.exitNodes = bodyFlow.exitNodes;
	
	return catchFlow;
}

private ControlFlow processBreak(int identifier, Statement breakNode) {
	ControlFlow breakFlow = ControlFlow({}, 0, {});
	
	addBreakNode(identifier);
	breakFlow.entryNode = identifier;
	
	return breakFlow;
}

private ControlFlow processContinue(int identifier, Statement continueNode) {
	ControlFlow continueFlow = ControlFlow({}, 0, {});
	
	addContinueNode(identifier);
	continueFlow.entryNode = identifier;
	
	return continueFlow;
}

private ControlFlow processReturn(int identifier, Statement returnNode) {
	ControlFlow returnFlow = ControlFlow({}, 0, {});
	
	addReturnNode(identifier);
	returnFlow.entryNode = identifier;
	
	return returnFlow;
}

private ControlFlow processThrow(int identifier, Statement throwNode) {
	ControlFlow throwFlow = ControlFlow({}, 0, {});
	
	addThrowNode(identifier);
	throwFlow.entryNode = identifier;
	
	return throwFlow;
}

private ControlFlow processStatement(int identifier, Statement statement) {
	return ControlFlow({}, identifier, {identifier});
}


/*********
 * Tests *
 *********/
test bool testConnector() {
	Graph[int] firstFlow = { <0, 1> };
	Graph[int] secondFlow = { <2, 3> };
	Graph[int] thirdFlow = { <4, 5>, <5, 6>	};
	
	list[ControlFlow] graphs = [
		ControlFlow(firstFlow, 0, {0, 1}),
		ControlFlow(secondFlow, 2, {3}),
		ControlFlow(thirdFlow, 4, {6})
	];
	
	println(connectControlFlows(graphs));
	
	return true;
}