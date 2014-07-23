module ControlDependence::ControlDependence

import lang::java::m3::AST;
import ListRelation;
import List;
import IO;
import ADT;
import ControlDependence::Dominance;

public int START = -1;
public int STOP = -2;
//ENTRY is a predict node with one edge labeled "T" going to START and another labeled "F" going to STOP;
public int ENTRY = -3;

public map[int, int] buildDependence(CF cf, list[int] nodes){
	flow = addCommonNodestoFlow(cf);
	nodes = nodes + START + STOP + ENTRY;
	map[int, int] postDominance = buildDominance(invert(flow), STOP, nodes);
	map[int, list[int]] dominators = getDominators(postDominance, STOP, nodes);
	lrel[int, int] examinedEdges = [];
	for(<node1, node2> <- flow, node2 notin dominators[node1]){
		examinedEdges += <node1, node2>;
	}
	
	return ;
}

public lrel[int, int] addCommonNodestoFlow(CF cf){
	return [<ENTRY, START>, <ENTRY, STOP>, <START, cf.firstStatement>] + cf.cflow + [<s, STOP> | s <- cf.lastStatements];
}