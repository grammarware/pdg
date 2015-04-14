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


public Graph[int] createPDT(FlowGraph controlFlow, list[int] unprocessedNodes) {
	Graph[int] postDominatorTree = {};
	int mergeNode = -1;
	list[int] mergeNodes = [];
	list[int] splitNodes = [];
	
	int switchNode = -1;
	list[int] caseNodes = [];
	list[int] switchNodes = [];
	
	for(treeNode <- unprocessedNodes) {
		set[int] predecessors = predecessors(controlFlow.edges, treeNode);
		
		if(isMergeNode(predecessors)) {
			mergeNode = treeNode;
		}
		
		if(isSwitchNode(treeNode)) {
			switchNode = treeNode;
		}
		
		if(isCaseNode(treeNode)) {
			println(predecessors);
			switchNodes += getOneFrom(predecessors);;
			caseNodes += treeNode;
		}
		
		for(predecessor <- predecessors, predecessor in unprocessedNodes) {
			set[int] successors = successors(controlFlow.edges, predecessor);
			
			if(isConditional(predecessor) || isLoop(predecessor)) {
				mergeNodes += mergeNode;
				splitNodes += [predecessor];
				unprocessedNodes -= predecessor;
			} else {
				postDominatorTree += <treeNode, predecessor>;
				unprocessedNodes -= predecessor;
			}
		}		
	}

	for(edge <- zip(mergeNodes, splitNodes)) {
		postDominatorTree += edge;
	}
	
	for(edge <- zip(caseNodes, switchNodes)) {
		postDominatorTree += edge;
	}
	
	println(mergeNodes);
	println(splitNodes);
	
	println(switchNodes);
	println(caseNodes);
	
	return postDominatorTree;
}

private bool isSwitchNode(int identifier) {
	switch(resolveIdentifier(identifier)) {
		case \switch(_, _): {
			return true;
		}
		default: {
			return false;
		}
	}
}

private bool isCaseNode(int identifier) {
	switch(resolveIdentifier(identifier)) {
		case \case(_): {
			return true;
		}
		case \defaultCase(): {
			return true;
		}
		default: {
			return false;
		}
	}
}

private bool isMergeNode(set[int] predecessors) {
	if(size(predecessors) > 1) {
		return true;
	}

	return false;
}

private bool isLoop(int identifier) {
	switch(resolveIdentifier(identifier)) {
		case forNode: \for(_, _, _): {
			return true;
		}
		case forNode: \for(_, _, _, _): {
			return true;
		}
		case whileNode: \while(condition, body): {
			return true;
		}
		case doNode: \do(body, condition): {
			return true;
		}
		default: {
			return false;
		}
	}
}



private bool isConditional(int identifier) {
	switch(resolveIdentifier(identifier)) {
		case \if(_, _): {
			return true;
		} 
		case \if(_, _, _): {
			return true;
		}
		default: {
			return false;
		}
	}
}