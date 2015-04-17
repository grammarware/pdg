module graph::control::flow::CFG

import Prelude;
import List;

import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::control::DataStructures;
import graph::control::flow::JumpEnvironment;

// A counter to identify nodes.
private int nodeIdentifier = 0;

// Storage for all the visited nodes with their identifier as key.
private map[int, node] nodeEnvironment = ();

private int getIdentifier() {
	int identifier = nodeIdentifier;
	
	nodeIdentifier += 1;
	
	return identifier;
}

public set[int] getNodeIdentifiers() {
	return domain(nodeEnvironment);
}

public node resolveIdentifier(int identifier) {
	return nodeEnvironment[identifier];
}

public str getNodeName(int identifier) {
	if(/^<name:\w*>/ := "<nodeEnvironment[identifier]>") {
		return name;
	}
	
	return "";
}

public FlowGraph createCFG(node tree) {
	nodeEnvironment = ();
	nodeIdentifier = 0;
	
	FlowGraph controlFlowGraph = createControlFlowGraph(tree);
	
	controlFlowGraph.exitNodes += getReturnNodes();
	
	return controlFlowGraph;
}

private int storeNode(node treeNode) {
	int identifier = getIdentifier();

	nodeEnvironment[identifier] = treeNode;
	
	return identifier;
}

private FlowGraph createControlFlowGraph(node tree) {
	FlowGraph flowGraph;
	int identifier;
	
	top-down-break visit(tree) {
		case blockNode: \block(body): {
			flowGraph = processBlock(body); 
		}
		case ifNode: \if(condition, thenBranch): {
			identifier = storeNode(ifNode);
			flowGraph = processIf(identifier, condition, thenBranch);
		}
		case ifNode: \if(condition, thenBranch, elseBranch): {
			identifier = storeNode(ifNode);
			flowGraph = processIfElse(identifier, condition, thenBranch, elseBranch);
		}
		case forNode: \for(_, _, _): {
			identifier = storeNode(forNode);
			flowGraph = processFor(identifier, forNode);
		}
		case forNode: \for(_, _, _, _): {
			identifier = storeNode(forNode);
			flowGraph = processFor(identifier, forNode);
		}
		case whileNode: \while(condition, body): {
			identifier = storeNode(whileNode);
			flowGraph = processWhile(identifier, condition, body);
		}
		case doNode: \do(body, condition): {
			identifier = storeNode(doNode);
			flowGraph = processDoWhile(identifier, body, condition);
		}
		case switchNode: \switch(expression, statements): {
			identifier = storeNode(switchNode);
			flowGraph = processSwitch(identifier, expression, statements);
		}
		case breakNode: \break(): {
			identifier = storeNode(breakNode);
			flowGraph = processBreak(identifier, breakNode);
		}
		case breakNode: \break(_): {
			identifier = storeNode(breakNode);
			flowGraph = processBreak(identifier, breakNode);
		}
		case continueNode: \continue(): {
			identifier = storeNode(continueNode);
			flowGraph = processContinue(identifier, continueNode);
		}
		case continueNode: \continue(_): {
			identifier = storeNode(continueNode);
			flowGraph = processContinue(identifier, continueNode);
		}
		case returnNode: \return(): {
			identifier = storeNode(returnNode);
			flowGraph = processReturn(identifier, returnNode);
		}
		case returnNode: \return(_): {
			identifier = storeNode(returnNode);
			flowGraph = processReturn(identifier, returnNode);
		}
		case throwNode: \throw(_): {
			identifier = storeNode(throwNode);
			flowGraph = processThrow(identifier, throwNode);
		}
		case Statement statement: {
			identifier = storeNode(statement);
			flowGraph = processStatement(identifier, statement);
		}
	}
	
	return flowGraph;
}

private FlowGraph connectFlowGraphs(list[FlowGraph] flowGraphs) {
	tuple[FlowGraph popped, list[FlowGraph] rest] popTuple = pop(flowGraphs);
	
	FlowGraph first = popTuple.popped;
	FlowGraph connectedFlowGraph = first;
	
	if(size(popTuple.rest) >= 2) {
		popTuple = pop(popTuple.rest);
		FlowGraph second = popTuple.popped;
		
		connectedFlowGraph.edges = first.edges 
							+ second.edges 
							+ createConnectionEdges(first, second);
	
		FlowGraph successorGraph = connectFlowGraphs(popTuple.rest);
		connectedFlowGraph.edges = connectedFlowGraph.edges 
							+ successorGraph.edges 
							+ createConnectionEdges(second, successorGraph);
		connectedFlowGraph.exitNodes = successorGraph.exitNodes;
	} else if(size(popTuple.rest) >= 1) {
		popTuple = pop(popTuple.rest);
		connectedFlowGraph.edges = connectedFlowGraph.edges
							+ popTuple.popped.edges 
							+ createConnectionEdges(connectedFlowGraph, popTuple.popped);
		connectedFlowGraph.exitNodes = popTuple.popped.exitNodes;
	}
	
	return connectedFlowGraph;
}

private Graph[int] createConnectionEdges(FlowGraph first, FlowGraph second) {
	return first.exitNodes * {second.entryNode};
}

test bool testConnector() {
	Graph[int] firstFlow = { <0, 1> };
	Graph[int] secondFlow = { <2, 3> };
	Graph[int] thirdFlow = { <4, 5>, <5, 6>	};
	
	list[FlowGraph] graphs = [
		FlowGraph(firstFlow, 0, {0, 1}),
		FlowGraph(secondFlow, 2, {3}),
		FlowGraph(thirdFlow, 4, {6})
	];
	
	println(connectFlowGraphs(graphs));
	
	return true;
}

private FlowGraph processBlock(list[Statement] body) {
	list[FlowGraph] flowGraphs = [];
	
	for(statement <- body) {
		flowGraphs += createControlFlowGraph(statement);
	}
	
	return connectFlowGraphs(flowGraphs);
}

private FlowGraph createConditionalBranchFlow(Statement branch) {
	if(\block(body) := branch) {
		return processBlock(body);
	}
	
	return createControlFlowGraph(branch);
}

private FlowGraph processIf(int identifier, Expression condition, Statement thenBranch) {
	FlowGraph ifFlow = FlowGraph({}, 0, {});
	
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	FlowGraph thenFlow = createConditionalBranchFlow(thenBranch);
	
	ifFlow.edges += thenFlow.edges + createConnectionEdges(ifFlow, thenFlow);
	ifFlow.exitNodes += thenFlow.exitNodes;
	
	return ifFlow;
}

private FlowGraph processIfElse(int identifier, Expression condition, Statement thenBranch, Statement elseBranch) {
	FlowGraph ifElseFlow = FlowGraph({}, 0, {});
	
	ifElseFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifElseFlow.exitNodes += {identifier};
	
	FlowGraph thenFlow = createConditionalBranchFlow(thenBranch);
	
	ifElseFlow.edges += thenFlow.edges + createConnectionEdges(ifElseFlow, thenFlow);
	
	FlowGraph elseFlow = createConditionalBranchFlow(elseBranch);
	
	ifElseFlow.edges += elseFlow.edges + createConnectionEdges(ifElseFlow, elseFlow);
	ifElseFlow.exitNodes += elseFlow.exitNodes + thenFlow.exitNodes;
	ifElseFlow.exitNodes -= {identifier};
	
	return ifElseFlow;
}

private FlowGraph processFor(int identifier, Statement forNode) {
	FlowGraph forFlow = FlowGraph({}, 0, {});
	
	forFlow.entryNode = identifier;
	forFlow.exitNodes += {identifier};
	
	FlowGraph bodyFlow;
	
	scopeDown();
	
	if(\for(_, _, _,body) := forNode) {
		bodyFlow = createControlFlowGraph(body);
	} else if(\for(_, _, body) := forNode) {
		bodyFlow = createControlFlowGraph(body);
	}
	
	bodyFlow.exitNodes += getContinueNodes();
	
	forFlow.edges += bodyFlow.edges;
	forFlow.edges += createConnectionEdges(forFlow, bodyFlow);
	forFlow.edges += createConnectionEdges(bodyFlow, forFlow);
		
	forFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return forFlow;
}

private FlowGraph processWhile(int identifier, Expression condition, Statement body) {
	FlowGraph whileFlow = FlowGraph({}, 0, {});
	
	whileFlow.entryNode = identifier;
	whileFlow.exitNodes += {identifier};
	
	scopeDown();
	
	FlowGraph bodyFlow = createControlFlowGraph(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	whileFlow.edges += bodyFlow.edges;
	whileFlow.edges += createConnectionEdges(bodyFlow, whileFlow);
	whileFlow.edges += createConnectionEdges(whileFlow, bodyFlow);
	
	whileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return whileFlow;
}

private FlowGraph processDoWhile(int identifier, Statement body, Expression condition) {
	FlowGraph doWhileFlow = FlowGraph({}, 0, {});
	
	scopeDown();
	
	// Process the body first, as it is always executed once.
	FlowGraph bodyFlow = createControlFlowGraph(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	doWhileFlow.entryNode = identifier;
	doWhileFlow.exitNodes += {identifier};
	
	doWhileFlow.edges += bodyFlow.edges;
	doWhileFlow.edges += createConnectionEdges(bodyFlow, doWhileFlow);
	
	doWhileFlow.entryNode = bodyFlow.entryNode;
	doWhileFlow.edges += createConnectionEdges(doWhileFlow, bodyFlow);
	
	doWhileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return doWhileFlow;
}

private list[FlowGraph] processCases(list[Statement] statements) {
	FlowGraph caseFlow = FlowGraph({}, 0, {});
	
	tuple[node popped, list[node] remainder] popTuple = pop(statements);
	FlowGraph caseNode = createControlFlowGraph(popTuple.popped);
	statements = popTuple.remainder;
	
	caseFlow.entryNode = caseNode.entryNode;
	caseFlow.exitNodes = caseNode.exitNodes;
	
	bool isNotDefault(node treeNode) = !(\defaultCase() := treeNode);
	bool isNotCase(node treeNode) = (!(\case(_) := treeNode) && isNotDefault(treeNode));
	
	list[node] caseBody = takeWhile(statements, isNotCase);
	
	FlowGraph caseBodyFlow = processBlock(caseBody);
	statements -= caseBody;
	
	caseFlow.edges = caseBodyFlow.edges + createConnectionEdges(caseFlow, caseBodyFlow);
	caseFlow.exitNodes = caseBodyFlow.exitNodes;
	
	list[FlowGraph] caseFlows = [caseFlow];
	
	if(size(statements) >= 1) {
		caseFlows += processCases(statements); 
	}
	
	return caseFlows;
}

private FlowGraph processSwitch(int identifier, Expression expression, list[Statement] statements) {
	FlowGraph switchFlow = FlowGraph({}, 0, {});
	
	switchFlow.entryNode = identifier;
	switchFlow.exitNodes = {identifier};
	
	list[FlowGraph] caseFlows = processCases(statements);
	set[int] finalExitNodes = {};
	
	for(caseFlow <- caseFlows) {
		switchFlow.edges += caseFlow.edges + createConnectionEdges(switchFlow, caseFlow);
		switchFlow.exitNodes += caseFlow.exitNodes;
		
		// Previous loop's exit nodes are now bound. Remove them.
		switchFlow.exitNodes -= finalExitNodes;
		
		finalExitNodes = caseFlow.exitNodes;
	}
	
	switchFlow.exitNodes = finalExitNodes + getBreakNodes();
	
	return switchFlow;
}

private FlowGraph processBreak(int identifier, Statement breakNode) {
	FlowGraph breakFlow = FlowGraph({}, 0, {});
	
	addBreakNode(identifier);
	breakFlow.entryNode = identifier;
	
	return breakFlow;
}

private FlowGraph processContinue(int identifier, Statement continueNode) {
	FlowGraph continueFlow = FlowGraph({}, 0, {});
	
	addContinueNode(identifier);
	continueFlow.entryNode = identifier;
	
	return continueFlow;
}

private FlowGraph processReturn(int identifier, Statement returnNode) {
	FlowGraph returnFlow = FlowGraph({}, 0, {});
	
	addReturnNode(identifier);
	returnFlow.entryNode = identifier;
	
	return returnFlow;
}

private FlowGraph processThrow(int identifier, Statement throwNode) {
	FlowGraph throwFlow = FlowGraph({}, 0, {});
	
	addReturnNode(identifier);
	throwFlow.entryNode = identifier;
	
	return throwFlow;
}

private FlowGraph processStatement(int identifier, Statement statement) {
	return FlowGraph({}, identifier, {identifier});
}