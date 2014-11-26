module Visualization::PDTvis

import Types;
import PDG;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import lang::java::m3::AST;
import IO;
import List;
import Map;
import Set;
import ListRelation;
import ControlDependence::ControlFlow;
import ControlDependence::Dominance;
import ControlDependence::ControlDependence;
import String;
import Utils::Figure;

public str HEADER = "\n";

//displayPDT(|project://JavaTest/src/PDG/Sum.java|, 0);
public void displayPDT(loc project, int methNum){
	meth = getMethodAST(project)[methNum];
	CF cf = getControlFlow(meth);
	statements = getStatements();
	list[int] nodes = toList(domain(statements)) + [-1, -2, -3];
	flow = addCommonNodestoFlow(cf);
	map[int, int] postDominance = buildDominance(invert(flow), -2, nodes);
	render("Post Dominator Tree", buildPDT(postDominance, nodes, statements));
}

private Figure buildPDT(map[int, int] pd, list[int] nodes, map[int, Statement] statements){
	str getHeader() { return HEADER; }
	list[Edge] edges = buildEdges(pd);
	Figure exitNode = box(text("Exit"), id("-2"), size(10), fillColor("red"), gap(10));
	Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] boxes = [exitNode, startNode, entryNode] + [statementNode(n, statements[n]) | n <- (nodes - [-1, -2, -3])];
	return vcat([text(getHeader,font("monaco"),fontSize(13)),
			graph(boxes, edges, hint("layered"), vgap(20), hgap(30))], gap(5));
}

private Figure statementNode(int n, Statement stat){
	loc location = getLoc(stat);
	return box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10),
			onMouseEnter(void() {setBrowserHeader(location);}),
			onMouseDown(goToSource(location)));
}

private list[Edge] buildEdges(map[int, int] pd){
	return [edge("<pd[k]>", "<k>", toArrow(ellipse(size(5),fillColor("black")))) | k <- pd];					
}

private void setBrowserHeader(loc location) {
	HEADER = "<center("<location>", 30)>";
}