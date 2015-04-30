module graph::control::dependence::CDG

import Prelude;
import graph::DataStructures;
import analysis::graphs::Graph;

private map[int, int] getImmediatePostDominators(Graph[int] postDominator) {
	map[int, int] immediatePostDominators = ();
	
	immediatePostDominators[EXITNODE] = EXITNODE;
	for(<from, to> <- postDominator) {
		immediatePostDominators[to] = from;
	}
	
	return immediatePostDominators;
}

private Graph[int] augmentFlowGraph(ControlFlow controlFlow) {
	Graph[int] augmentedGraph = controlFlow.graph;
	
	augmentedGraph += { <STARTNODE, controlFlow.entryNode> };
	
	for(exitNode <- controlFlow.exitNodes) {
		augmentedGraph += { <exitNode, EXITNODE> };
	}
	
	augmentedGraph += { <ENTRYNODE, STARTNODE>, <ENTRYNODE, EXITNODE> };
	
	return augmentedGraph;
}

public MethodData createCDG(MethodData methodData) {
	ControlDependence controlDependence = ControlDependence({});
	Graph[int] augmentedGraph = augmentFlowGraph(methodData.controlFlow);
	
	map[int, set[int]] dependencies = ();
	
	for(treeNode <- carrier(augmentedGraph)) {
		dependencies[treeNode] = {};
	}
	
	Graph[int] inspectionEdges = { <from, to> | <from, to> <- augmentedGraph, from notin reach(methodData.postDominator.tree, { to }) - { to } };
	
	for(<from, to> <- inspectionEdges) {
		// Immediate dominator (idom)
		int idom = getOneFrom(predecessors(methodData.postDominator.tree, from));
		list[int] pathNodes = shortestPathPair(methodData.postDominator.tree, idom, to) - idom;
		
		for(dependency <- pathNodes, dependency != from) {
			dependencies[dependency] += { from };
		}
	}
	
	for(treeNode <- carrier(augmentedGraph) - { STARTNODE, EXITNODE, ENTRYNODE }) {
		bool foundDependency = false;
		
		for(dependency <- dependencies[treeNode]) {
			if(size(dependencies[treeNode]) == 1 || dependencies[dependency] == dependencies[treeNode] - dependency) {
				controlDependence.graph += { <dependency, treeNode> };
				foundDependency = true;
				break;
			}
		}
		
		if(!foundDependency) {
			controlDependence.graph += { <ENTRYNODE, treeNode> };
		}
	}
	
	methodData.controlDependence = controlDependence;
	
	return methodData;
}