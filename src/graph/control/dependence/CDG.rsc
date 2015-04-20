module graph::control::dependence::CDG

import Prelude;
import analysis::graphs::Graph;
import graph::control::DataStructures;

private map[int, int] getImmediatePostDominators(Graph[int] postDominator) {
	map[int, int] immediatePostDominators = ();
	
	immediatePostDominators[EXITNODE] = EXITNODE;
	for(<from, to> <- postDominator) {
		immediatePostDominators[to] = from;
	}
	
	return immediatePostDominators;
}

private Graph[int] augmentFlowGraph(FlowGraph controlFlow) {
	Graph[int] augmentedGraph = controlFlow.edges;
	
	augmentedGraph += { <STARTNODE, controlFlow.entryNode> };
	
	for(exitNode <- controlFlow.exitNodes) {
		augmentedGraph += { <exitNode, EXITNODE> };
	}
	
	augmentedGraph += { <ENTRYNODE, STARTNODE>, <ENTRYNODE, EXITNODE> };
	
	return augmentedGraph;
}

public Graph[int] createCDG(FlowGraph controlFlow, Graph[int] postDominator) {
	Graph[int] controlDependenceGraph = {};
	Graph[int] augmentedGraph = augmentFlowGraph(controlFlow);
	
	map[int, set[int]] dependencies = ();
	
	for(treeNode <- carrier(augmentedGraph)) {
		dependencies[treeNode] = {};
	}
	
	Graph[int] inspectionEdges = { <from, to> | <from, to> <- augmentedGraph, from notin reach(postDominator, { to }) - { to } };
	
	for(<from, to> <- inspectionEdges) {
		int idom = getOneFrom(predecessors(postDominator, from));
		list[int] pathNodes = shortestPathPair(postDominator, idom, to) - idom;
		
		for(dependency <- pathNodes, dependency != from) {
			dependencies[dependency] += { from };
		}
	}
	
	for(treeNode <- carrier(augmentedGraph) - { STARTNODE, EXITNODE, ENTRYNODE }) {
		bool foundDependency = false;
		
		for(dependency <- dependencies[treeNode]) {
			if(size(dependencies[treeNode]) == 1 || dependencies[dependency] == dependencies[treeNode] - dependency) {
				controlDependenceGraph += <dependency, treeNode>;
				foundDependency = true;
				break;
			}
		}
		
		if(!foundDependency) {
			controlDependenceGraph += <ENTRYNODE, treeNode>;
		}
	}
	
	return controlDependenceGraph;
}