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

private map[int, set[int]] dominators = ();
private map[int, set[int]] dominations = ();

private Graph[int] reverseEdges(Graph[int] edges) {
	Graph[int] reversedTree = {};
	
	for(<int from, int to> <- edges) {
		reversedTree += <to, from>;
	}
	
	return reversedTree;
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

public MethodData createPDT(MethodData methodData) {
	PostDominator postDominator = PostDominator({}, (), ());
	
	Graph[int] augmentedGraph = augmentFlowGraph(methodData.controlFlow);
	Graph[int] reversedTree = reverseEdges(augmentedGraph);
	
	set[int] nodes = carrier(reversedTree) - top(reversedTree);
	
	for(treeNode <- carrier(reversedTree)) {
		dominations[treeNode] = {};
		dominators[treeNode] = {};
	}
	
	for(treeNode <- carrier(reversedTree)) {
		set[int] exclusiveReach = reachX(reversedTree, top(reversedTree), { treeNode });
		set[int] domination = nodes - { treeNode } - exclusiveReach;
		
		for(dominatedNode <- domination) {
			dominations[dominatedNode] += { treeNode };
			dominators[treeNode] = domination;
		}
	}
	
	for(treeNode <- carrier(reversedTree)) {
		for(dominator <- dominations[treeNode]) {
			if(dominations[dominator] == dominations[treeNode] - dominator) {
				postDominator.tree += { <dominator, treeNode> };
				break;
			}
		}
	}
	
	postDominator.dominations = dominations;
	postDominator.dominators = dominators;
	methodData.postDominator = postDominator;
	
	return methodData;
}