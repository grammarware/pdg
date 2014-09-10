module CFvis

import ADT;
import PDG;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;
import Map;
import Set;
import ControlDependence::ControlFlow;
import ControlDependence::ControlDependence;

//displayCFG(|project://JavaTest/src/PDG/dataFlow/DataDependence.java|);
public void displayCFG(loc project){
	meth = getMethodAST(project)[0];
	CF cf = getControlFlow(meth);
	statements = getStatements();
	list[int] nodes = toList(domain(statements)) + [-1, -2, -3];
	flow = addCommonNodestoFlow(cf);

	render(buildCFG(flow, nodes));
}

private Figure buildCFG(lrel[int, int] flow, list[int] nodes){
	//list[Edge] edges = [edge("1", "4", toArrow(ellipse(size(5),fillColor("black"))), label(text("aaa")), gap(5))];
	list[Edge] edges = buildEdges(flow);
	Figure exitNode = box(text("Exit"), id("-2"), size(10), fillColor("red"), gap(10));
	Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] boxes = buildNodes(nodes) + exitNode + startNode + entryNode;
	return graph(boxes, edges, hint("layered"), vgap(20), hgap(30));
}

private list[Figure] buildNodes(list[int] nodes){
	return [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- (nodes - [-1, -2, -3])];
	//return nodes;
}

private list[Edge] buildEdges(lrel[int, int] flow){
	list[Edge] edges = [];
	for(<stat1, stat2> <- flow){	
		edges += [edge("<stat1>", "<stat2>", toArrow(ellipse(size(5),fillColor("black"))))];					
	}
	
	return edges;
}