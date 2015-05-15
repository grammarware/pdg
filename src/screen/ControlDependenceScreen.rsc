module screen::ControlDependenceScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::AST;

import screen::Screen;
import extractors::Project;

import graph::DataStructures;
import creator::CFGCreator;
import graph::control::PDT;
import graph::control::dependence::CDG;

@doc{
	To run a test:
		displayControlDependenceGraph(|project://JavaTest|, "testPDT");
		displayControlDependenceGraph(|project://JavaTest|, "testPDT2");
}
public void displayControlDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel);
	PostDominators postDominators = ( method : createPDT(method, controlFlows[method]) | method <- controlFlows );
	ControlDependences controlDependences = 
					( 
						method : createCDG(method, controlFlows[method], postDominators[method]) 
						| method <- postDominators 
					);
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- controlDependences) {
		edges += createEdges(method.name, controlDependences[method].graph, "solid", "blue");
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}