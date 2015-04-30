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
	
	// Maps a node to all the nodes that it depends on.
	map[int, set[int]] dependencies = ();
	// Maps a node to all the nodes that depend on it.
	map[int, set[int]] controls = ();
	
	for(treeNode <- carrier(augmentedGraph)) {
		dependencies[treeNode] = {};
		controls[treeNode] = {};
	}
	
	Graph[int] inspectionEdges = { <from, to> | <from, to> <- augmentedGraph, from notin reach(methodData.postDominator.tree, { to }) - { to } };
	
	for(<from, to> <- inspectionEdges) {
		// Immediate dominator (idom)
		int idom = getOneFrom(predecessors(methodData.postDominator.tree, from));
		list[int] pathNodes = shortestPathPair(methodData.postDominator.tree, idom, to) - idom;
		
		for(pathNode <- pathNodes, pathNode != from) {
			dependencies[pathNode] += { from };
			controls[from] += { pathNode };
		}
	}
	
	for(treeNode <- sort(carrier(augmentedGraph)) - { STARTNODE, EXITNODE, ENTRYNODE }) {
		for(controller <- sort(dependencies[treeNode])) {
			if(size(dependencies[treeNode]) == 1 || (controls[controller] & dependencies[treeNode]) == {}) {
				controlDependence.graph += { <controller, treeNode> };
				break;
			}
		}
	}
	
	println(controls[-3]);
	
	methodData.controlDependence = controlDependence;
	
	return methodData;
}