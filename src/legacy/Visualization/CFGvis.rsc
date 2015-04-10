module Visualization::CFGvis

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
import String;
import graph::control::Flow;
import ControlDependence;
import Utils::Figure;

public str HEADER = "\n";

//displayCFG(|project://pdg-JavaTest/src/PDG/Sum.java|, 0);
public void displayCFG(loc project, int methNum){
	meth = getMethodAST(project)[methNum];
	ControlFlow cf = getControlFlow(meth);
	statements = getStatements();
	list[int] nodes = toList(domain(statements)) + [-1, -2, -3];
	flow = addCommonNodestoFlow(cf);
	render("Control Flow Graph", buildCFG(flow, nodes, statements));
}

private Figure buildCFG(lrel[int, int] flow, list[int] nodes, map[int, Statement] statements){
	str getHeader() { return HEADER; }
	list[Edge] edges = buildEdges(flow);
	Figure exitNode = box(text("Exit"), id("-2"), size(10), fillColor("red"), gap(10));
	Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] boxes = [statementNode(n, statements[n]) | n <- (nodes - [-1, -2, -3])] + exitNode + startNode + entryNode;
	
	return vcat([text(getHeader,font("GillSans"),fontSize(13)),
				graph(boxes, edges, hint("layered"), vgap(20), hgap(30))], gap(5));
}

private Figure statementNode(int n, Statement stat){
	loc location = getLoc(stat);
	return box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10), 
			onMouseEnter(void() {setBrowserHeader(location);}),
			onMouseDown(goToSource(location)));
}

private list[Edge] buildEdges(lrel[int, int] flow){
	list[Edge] edges = [];
	for(<stat1, stat2> <- flow){	
		edges += [edge("<stat1>", "<stat2>", toArrow(ellipse(size(5),fillColor("black"))))];					
	}	
	return edges;
}

private void setBrowserHeader(loc location) {
	HEADER = "<center("<location>", 30)>";
}