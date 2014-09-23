module Visualization::PDTvis

import ADT;
import PDG;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;
import Map;
import Set;
import ListRelation;
import ControlDependence::ControlFlow;
import ControlDependence::Dominance;
import ControlDependence::ControlDependence;
import Utils::Traversal;
import Utils::Relation;

//private int START = -1;
//private int STOP = -2;
////ENTRY is a predict node with one edge labeled "T" going to START and another labeled "F" going to STOP;
//private int ENTRY = -3;

//displayPDT(|project://JavaTest/src/PDG/Sum.java|);
public void displayPDT(loc project){
	meth = getMethodAST(project)[0];
	CF cf = getControlFlow(meth);
	statements = getStatements();
	list[int] nodes = toList(domain(statements)) + [-1, -2, -3];
	flow = addCommonNodestoFlow(cf);
	map[int, int] postDominance = buildDominance(invert(flow), -2, nodes);
	render(buildPDT(postDominance, nodes));
}

private Figure buildPDT(map[int, int] pd, list[int] nodes){
	list[Edge] edges = buildEdges(pd);
	Figure exitNode = box(text("Exit"), id("-2"), size(10), fillColor("red"), gap(10));
	Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] boxes = [exitNode, startNode, entryNode] + buildNodes(nodes);
	return graph(boxes, edges, hint("layered"), vgap(20), hgap(30));
}

private list[Figure] buildNodes(list[int] nodes){
	return [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- (nodes - [-1, -2, -3])];
}

private list[Edge] buildEdges(map[int, int] pd){
	return [edge("<pd[k]>", "<k>", toArrow(ellipse(size(5),fillColor("black")))) | k <- pd];					
}