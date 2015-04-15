@doc {
	Post-dominator tree.
	
	Used in conjunction with the Control
	Flow Graph to create the Control 
	Dependence Graph.
}
module graph::control::PDT

import Prelude;
import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::control::flow::CFG;
import graph::control::DataStructures;

public int EXITNODE = -1;
public int STARTNODE = -2;

private Graph[int] reverseEdges(Graph[int] edges) {
	Graph[int] reversedTree = {};
	
	for(<int from, int to> <- edges) {
		reversedTree += <to, from>;
	}
	
	return reversedTree;
}

public Graph[int] createPDT(FlowGraph controlFlow, list[int] unprocessedNodes) {
	Graph[int] postDominatorTree = {};

	map[int, set[int]] dominatedBy = ();
	map[int, set[int]] dominates = ();
	
	Graph[int] reversedTree = reverseEdges(controlFlow.edges);
	set[int] nodes = carrier(reversedTree) - top(reversedTree);
	
	for(treeNode <- carrier(reversedTree)) {
		dominatedBy[treeNode] = {};
		dominates[treeNode] = {};
	}
	
	for(treeNode <- carrier(reversedTree)) {
		set[int] exclusiveReach = reachX(reversedTree, top(reversedTree), { treeNode });
		set[int] domination = nodes - { treeNode } - exclusiveReach;
		
		for(dominatedNode <- domination) {
			dominatedBy[dominatedNode] += { treeNode };
			dominates[treeNode] = domination;
		}
	}
	
	for(treeNode <- carrier(reversedTree)) {
		bool foundIdom = false;
		
		for(dominator <- dominatedBy[treeNode]) {
			if(dominatedBy[dominator] == dominatedBy[treeNode] - dominator) {
				postDominatorTree += <dominator, treeNode>;
				foundIdom = true;
				break;
			}
		}
		
		// Top nodes do not have a unique immediate dominator. These nodes 
		// will be connected with the exit node in the graph.
		if(!foundIdom) {
			postDominatorTree += <EXITNODE, treeNode>;
		}
	}
	
	postDominatorTree += <controlFlow.entryNode, STARTNODE>;
	
	return postDominatorTree;
}