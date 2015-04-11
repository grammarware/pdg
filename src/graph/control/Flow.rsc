module graph::control::Flow

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

// A counter to identify nodes.
private int nodeIdentifier = 0;

// Storage for all the visited nodes with their identifier
// as key.
private map[int, node] nodeEnvironment = ();

data FlowGraph = FlowGraph(Graph[int] edges, int entryNode, set[int] exitNodes);

private int getIdentifier() {
	int identifier = nodeIdentifier;
	
	nodeIdentifier += 1;
	
	return identifier;
}

public FlowGraph createControlFlowGraph(node tree) {
	FlowGraph flowGraph;
	
	top-down-break visit(tree) {
		case \block(body): {
			flowGraph = processBlock(body); 
		}
		case ifNode: \if(condition, thenBranch): {
			flowGraph = processIf(condition, thenBranch);
		}
		case ifElseNode: \if(_, _, _): {
			flowGraph = processIfElse(ifElseNode);
		}
		case forNode: \for(_, _, _): {
			flowGraph = processFor(forNode);
		}
		case forNode: \for(_, _, _, _): {
			flowGraph = processFor(forNode);
		}
		case whileNode: \while(_, _): {
			flowGraph = processWhile(whileNode);
		}
		case doWhileNode: \do(_, _): {
			flowGraph = processDoWhile(doWhileNode);
		}
		case switchNode: \switch(_, _): {
			flowGraph = processSwitch(switchNode);
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

private FlowGraph processIf(Expression condition, Statement thenBranch) {
	FlowGraph ifFlow = FlowGraph({}, 0, {});
	
	int identifier = getIdentifier();
	nodeEnvironment[identifier] = condition;
	
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	FlowGraph thenFlow;
	
	if(\block(body) := thenBranch) {
		thenFlow = processBlock(body);
	} else {
		thenFlow = createFlowGraph(thenBranch);
	}
	
	ifFlow.edges += thenFlow.edges + createConnectionEdges(ifFlow, thenFlow);
	ifFlow.exitNodes += thenFlow.exitNodes;
	
	return ifFlow;
}

private FlowGraph processIfElse(Statement ifElseNode) {
	println(ifElseNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processFor(Statement forNode) {
	println(forNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processWhile(Statement whileNode) {
	println(whileNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processDoWhile(Statement doWhileNode) {
	println(doWhileNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processSwitch(Statement switchNode) {
	println(switchNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processBreak(Statement breakNode) {
	println(breakNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processContinue(Statement continueNode) {
	println(continueNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processReturn(Statement returnNode) {
	println(returnNode);
	
	return FlowGraph({}, 0, {});
}

private FlowGraph processStatement(Statement statement) {
	int identifier = getIdentifier();
	println(statement);
	
	return FlowGraph({}, identifier, {identifier});
}