module screen::ControlFlowScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import graph::DataStructures;
import extractors::Project;
import graph::control::flow::CFG;

@doc { 
	To run a test:
		displayControlFlowGraph(|project://pdg-JavaTest|, "testCDG");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	FlowGraph startFlowGraph = createCFG(methodAST, 0);
	
	int maxIdentifier = max(environmentDomain(startFlowGraph));
	list[FlowGraph] flowGraphs = [startFlowGraph];
	
	for(calledMethod <- startFlowGraph.calledMethods) {
		methodAST = getMethodASTEclipse(calledMethod, model = projectModel);
		
		flowGraph = createCFG(methodAST, maxIdentifier);
		flowGraphs += flowGraph;
		
		maxIdentifier = max(environmentDomain(flowGraph));
	}
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(flow <- flowGraphs) {
		edges += createEdges(flow);
		boxes += createBoxes(flow);
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	return |file://methodDoesNotExist|;
}

private list[Edge] createEdges(FlowGraph flowGraph) {
	list[Edge] edges = [];

	for(graphEdge <- flowGraph.edges) {
		edges += edge("<graphEdge.from>", "<graphEdge.to>", toArrow(box(size(10), fillColor("black"))));
	}
	
	edges += edge("ENTRY", "<flowGraph.entryNode>", toArrow(box(size(10), fillColor("black"))));
	
	for(exitNode <- flowGraph.exitNodes) {
		edges += edge("<exitNode>", "EXIT", toArrow(box(size(10), fillColor("black"))));
	}
	
	return edges;
}

private Figures createBoxes(FlowGraph flowGraph) {
	Figures boxes = [];
	
	for(treeNode <- environmentDomain(flowGraph)) {
		boxes += box(text("<treeNode>: <nodeName(flowGraph, treeNode)>"), id("<treeNode>"), size(50), fillColor("lightgreen"));
	}
	
	boxes += box(text("Entry"), id("ENTRY"), size(50), fillColor("lightblue"));
	boxes += box(text("Exit"), id("EXIT"), size(50), fillColor("lightblue"));
	
	return boxes;
}