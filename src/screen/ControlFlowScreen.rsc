module screen::ControlFlowScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import screen::Screen;
import graph::DataStructures;
import extractors::Project;


@doc {
	To run a test:
		displayControlFlowGraph(|project://JavaTest|, "testCDG");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel);
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- controlFlows) {
		edges += createEdges(method.name, controlFlows[method].graph, "solid", "blue");
		edges += edge("<method.name>:<ENTRYNODE>", "<method.name>:<controlFlows[method].entryNode>", 
						lineColor("blue"), toArrow(box(size(10), fillColor("blue"))));
		
		for(exitNode <- controlFlows[method].exitNodes) {
			edges += edge("<method.name>:<exitNode>", "<method.name>:<EXITNODE>", 
							lineColor("blue"), toArrow(box(size(10), fillColor("blue"))));
		}
		
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}