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

private map[int, set[int]] dominates = ();
private map[int, set[int]] dominatedBy = ();

private Graph[int] reverseEdges(Graph[int] edges) {
	Graph[int] reversedTree = {};
	
	for(<int from, int to> <- edges) {
		reversedTree += <to, from>;
	}
	
	return reversedTree;
}

public map[int, set[int]] getNodeDominators() {
	return dominatedBy;
}

public map[int, set[int]] getDominations() {
	return dominates;
}

public Graph[int] createPDT(FlowGraph controlFlow) {
	Graph[int] postDominatorTree = {};
	
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