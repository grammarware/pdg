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

import graph::DataStructures;
import graph::control::flow::CFG;

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

private Graph[int] augmentFlowGraph(FlowGraph controlFlow) {
	Graph[int] augmentedGraph = controlFlow.edges;
	
	augmentedGraph += { <STARTNODE, controlFlow.entryNode> };
	
	for(exitNode <- controlFlow.exitNodes) {
		augmentedGraph += { <exitNode, EXITNODE> };
	}
	
	augmentedGraph += { <ENTRYNODE, STARTNODE>, <ENTRYNODE, EXITNODE> };
	
	return augmentedGraph;
}

public Graph[int] createPDT(FlowGraph controlFlow) {
	Graph[int] postDominatorTree = {};
	Graph[int] augmentedGraph = augmentFlowGraph(controlFlow);
	Graph[int] reversedTree = reverseEdges(augmentedGraph);
	
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
		for(dominator <- dominatedBy[treeNode]) {
			if(dominatedBy[dominator] == dominatedBy[treeNode] - dominator) {
				postDominatorTree += <dominator, treeNode>;
				break;
			}
		}
	}
	
	return postDominatorTree;
}