module graph::control::flow::CFConnector

import Prelude;
import analysis::graphs::Graph;

import graph::DataStructures;


public ControlFlow connectControlFlows(list[ControlFlow] controlFlows) {
	if(isEmpty(controlFlows)) {
		return EmptyCF();
	}
	
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

public Graph[int] createConnectionEdges(ControlFlow first, ControlFlow second) {
	return first.exitNodes * {second.entryNode};
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