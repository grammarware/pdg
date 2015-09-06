@doc {
	Post-dominator tree.
	
	Used in conjunction with the Control
	Flow Graph to create the Control 
	Dependence Graph.
}
@contributor{René Bulsing - UvA MSc 2015}
@contributor{Vadim Zaytsev - UvA - http://grammarware.net}
module graph::control::PDT

import Prelude;
import analysis::graphs::Graph;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;


@doc{
	Maps the node to all nodes that dominate it.
}
private map[int, set[int]] dominators = ();
@doc{
	Maps the node to every node it dominates.
}
private map[int, set[int]] dominations = ();

private Graph[int] reverseEdges(Graph[int] edges)
	= {<to,from> | <int from, int to> <- edges};

private Graph[int] augmentFlowGraph(ControlFlow controlFlow)
	= controlFlow.graph
	+ { <STARTNODE, controlFlow.entryNode> }
	+ { <exitNode, EXITNODE> | exitNode <- controlFlow.exitNodes}
	+ { <ENTRYNODE, STARTNODE>, <ENTRYNODE, EXITNODE> };

public PostDominator createPDT(MethodData methodData, ControlFlow controlFlow) {
	PostDominator postDominator = PostDominator({}, (), ());
	
	Graph[int] augmentedGraph = augmentFlowGraph(controlFlow);
	Graph[int] reversedTree = reverseEdges(augmentedGraph);
	
	set[int] nodes = carrier(reversedTree) - top(reversedTree);
	
	for(treeNode <- carrier(reversedTree)) {
		dominations[treeNode] = {};
		dominators[treeNode] = {};
	}
	
	for(treeNode <- carrier(reversedTree)) {
		set[int] exclusiveReach = reachX(reversedTree, top(reversedTree), { treeNode });
		dominations[treeNode] = nodes - { treeNode } - exclusiveReach;
		
		for(dominatedNode <- dominations[treeNode]) {
			dominators[dominatedNode] += { treeNode };
		}
	}
	
	for(treeNode <- carrier(reversedTree)) {
		for(dominator <- dominators[treeNode]) {
			if((dominations[dominator] & dominators[treeNode]) == {}) {
				postDominator.tree += { <dominator, treeNode> };
				break;
			}
		}
	}
	
	postDominator.dominations = dominations;
	postDominator.dominators = dominators;
	
	return postDominator;
}