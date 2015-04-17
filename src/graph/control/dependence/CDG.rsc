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

public Graph[int] createCDG(Graph[int] controlFlow, Graph[int] postDominator, map[int, set[int]] dominations) {
	Graph[int] controlDependenceGraph = {};
	
	map[int, int] immediatePostDominators = getImmediatePostDominators(postDominator);
	map[int, set[int]] dependencies = ();
	
	for(treeNode <- carrier(controlFlow)) {
		dependencies[treeNode] = {};
	}
	
	dependencies[STARTNODE] = {};
	dependencies[EXITNODE] = {};
	
	for(treeNode <- carrier(controlFlow)) {
		int idom = immediatePostDominators[treeNode];
		set[int] exclusiveReach = reachX(controlFlow, { treeNode }, { idom }) - { treeNode };
		
		for(reachableNode <- exclusiveReach) {
			set[int] reachables = { reachableNode } + reachR(controlFlow, { treeNode }, { treeNode } + dominations[reachableNode]);

			for(reachable <- reachables) {
				dependencies[reachable] += { treeNode };
			}
		}
	}		
	
	for(treeNode <- carrier(controlFlow)) {
		bool foundDirectDependency = false;
		
		for(dependency <- dependencies[treeNode]) {
			if(dependencies[dependency] == dependencies[treeNode] - dependency) {
				controlDependenceGraph += <dependency, treeNode>;
				foundDirectDependency = true;
				break;
			}
		}
		
		// Top nodes are only dependant on the start node.
		if(!foundDirectDependency) {
			controlDependenceGraph += <STARTNODE, treeNode>;
		}
	}
	
	println(immediatePostDominators);
	println(dependencies);
	
	return controlDependenceGraph;
}