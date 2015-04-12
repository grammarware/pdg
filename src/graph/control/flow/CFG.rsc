module graph::control::flow::CFG

import Prelude;
import List;

import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::control::flow::JumpEnvironment;

data FlowGraph = FlowGraph(Graph[int] edges, int entryNode, set[int] exitNodes);

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

public FlowGraph createCFG(node tree) {
	nodeEnvironment = ();
	nodeIdentifier = 0;
	
	FlowGraph controlFlowGraph = createControlFlowGraph(tree);
	
	controlFlowGraph.exitNodes += getReturnNodes();
	
	return controlFlowGraph;
}

private FlowGraph createControlFlowGraph(node tree) {
	FlowGraph flowGraph;
	
	top-down-break visit(tree) {
		case \block(body): {
			flowGraph = processBlock(body); 
		}
		case \if(condition, thenBranch): {
			flowGraph = processIf(condition, thenBranch);
		}
		case \if(condition, thenBranch, elseBranch): {
			flowGraph = processIfElse(condition, thenBranch, elseBranch);
		}
		case forNode: \for(_, _, _): {
			flowGraph = processFor(forNode);
		}
		case forNode: \for(_, _, _, _): {
			flowGraph = processFor(forNode);
		}
		case \while(condition, body): {
			flowGraph = processWhile(condition, body);
		}
		case \do(body, condition): {
			flowGraph = processDoWhile(body, condition);
		}
		case \switch(expression, statements): {
			flowGraph = processSwitch(expression, statements);
		}
		case breakNode: \break(): {
			flowGraph = processBreak(breakNode);
		}
		case breakNode: \break(_): {
			flowGraph = processBreak(breakNode);
		}
		case continueNode: \continue(): {
			flowGraph = processContinue(continueNode);
		}
		case continueNode: \continue(_): {
			flowGraph = processContinue(continueNode);
		}
		case returnNode: \return(): {
			flowGraph = processReturn(returnNode);
		}
		case returnNode: \return(_): {
			flowGraph = processReturn(returnNode);
		}
		case Statement statement: {
			flowGraph = processStatement(statement);
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

private FlowGraph processIf(Expression condition, Statement thenBranch) {
	FlowGraph ifFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = condition;
	
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	FlowGraph thenFlow = createConditionalBranchFlow(thenBranch);
	
	ifFlow.edges += thenFlow.edges + createConnectionEdges(ifFlow, thenFlow);
	ifFlow.exitNodes += thenFlow.exitNodes;
	
	return ifFlow;
}

private FlowGraph processIfElse(Expression condition, Statement thenBranch, Statement elseBranch) {
	FlowGraph ifElseFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = condition;
	
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

private FlowGraph processFor(Statement forNode) {
	FlowGraph forFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = forNode;
	
	forFlow.entryNode = identifier;
	forFlow.exitNodes += {identifier};
	
	FlowGraph bodyFlow;
	
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
	
	return forFlow;
}

private FlowGraph processWhile(Expression condition, Statement body) {
	FlowGraph whileFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = condition;
	
	whileFlow.entryNode = identifier;
	whileFlow.exitNodes += {identifier};
	
	FlowGraph bodyFlow = createControlFlowGraph(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	whileFlow.edges += bodyFlow.edges;
	whileFlow.edges += createConnectionEdges(bodyFlow, whileFlow);
	whileFlow.edges += createConnectionEdges(whileFlow, bodyFlow);
	
	whileFlow.exitNodes += getBreakNodes();
	
	return whileFlow;
}

private FlowGraph processDoWhile(Statement body, Expression condition) {
	FlowGraph doWhileFlow = FlowGraph({}, 0, {});
	
	// Process the body first, as it is always executed once.
	FlowGraph bodyFlow = createControlFlowGraph(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = condition;
	
	doWhileFlow.entryNode = identifier;
	doWhileFlow.exitNodes += {identifier};
	
	doWhileFlow.edges += bodyFlow.edges;
	doWhileFlow.edges += createConnectionEdges(bodyFlow, doWhileFlow);
	
	doWhileFlow.entryNode = bodyFlow.entryNode;
	doWhileFlow.edges += createConnectionEdges(doWhileFlow, bodyFlow);
	
	doWhileFlow.exitNodes += getBreakNodes();
	
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

private FlowGraph processSwitch(Expression expression, list[Statement] statements) {
	FlowGraph switchFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = expression;
	
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

private FlowGraph processBreak(Statement breakNode) {
	FlowGraph breakFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = breakNode;
	addBreakNode(identifier);
	
	breakFlow.entryNode = identifier;
	
	return breakFlow;
}

private FlowGraph processContinue(Statement continueNode) {
	FlowGraph continueFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = continueNode;
	addContinueNode(identifier);
	
	continueFlow.entryNode = identifier;
	
	return continueFlow;
}

private FlowGraph processReturn(Statement returnNode) {
	FlowGraph returnFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = returnNode;
	addReturnNode(identifier);
	
	returnFlow.entryNode = identifier;
	
	return returnFlow;
}

private FlowGraph processStatement(Statement statement) {
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = statement;
	
	return FlowGraph({}, identifier, {identifier});
}