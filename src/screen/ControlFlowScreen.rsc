module screen::ControlFlowScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import screen::Screen;
import graph::DataStructures;
import graph::factory::GraphFactory;
import extractors::Project;


@doc{
	To run a test:
		displayControlFlowGraph(|project://JavaTest|, "testCDG");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- controlFlows) {
		edges += createEdges(method.name, controlFlows[method].graph, "solid", "blue");
		edges += edge("<method.name>:<ENTRYNODE>", "<method.name>:<controlFlows[method].entryNode>", 
						lineColor("blue"), toArrow(box(size(10), fillColor("blue"))));
		edges = (edges 
				| it + edge("<method.name>:<exitNode>", "<method.name>:<EXITNODE>", 
							lineColor("blue"), toArrow(box(size(10), fillColor("blue")))) 
				| exitNode <- controlFlows[method].exitNodes
				);
		
		boxes += createBoxes(method);
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

public void displayControlFlowGraph(loc project, str methodName, str fileName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, fileName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- controlFlows) {
		edges += createEdges(method.name, controlFlows[method].graph, "solid", "blue");
		edges += edge("<method.name>:<ENTRYNODE>", "<method.name>:<controlFlows[method].entryNode>", 
						lineColor("blue"), toArrow(box(size(10), fillColor("blue"))));
		
		edges = (edges 
				| it + edge("<method.name>:<exitNode>", "<method.name>:<EXITNODE>", 
							lineColor("blue"), toArrow(box(size(10), fillColor("blue")))) 
				| exitNode <- controlFlows[method].exitNodes
				);
		
		boxes += createBoxes(method);
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}