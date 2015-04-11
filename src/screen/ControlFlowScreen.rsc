module screen::ControlFlowScreen

import IO;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import extractors::Project;
import graph::control::Flow;

@doc {
	To run a test:
		displayControlFlowGraph(|project://pdg-JavaTest/src/PDG|, "testBreak1");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	FlowGraph flowGraph = createControlFlowGraph(methodAST);
	
	render(graph(createBoxes(flowGraph), createEdges(flowGraph), hint("layered"), gap(100)));
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
		edges += edge("<graphEdge.from>", "<graphEdge.to>");
	}
	
	return edges;
}

private Figures createBoxes(FlowGraph flowGraph) {
	Figures boxes = [];
	
	for(treeNode <- order(flowGraph.edges)) {
		boxes += box(text("<treeNode>"), id("<treeNode>"), size(50), fillColor("lightgreen"));
	}
	
	return boxes;
}