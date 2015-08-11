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
import graph::control::dependence::CDG;
import graph::factory::GraphFactory;

@doc{
	To run a test:
		displayControlDependenceGraph(|project://JavaTest|, "testPDT");
		displayControlDependenceGraph(|project://JavaTest|, "testPDT2");
}
public void displayControlDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	ControlDependences controlDependences = createControlDependences(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- controlDependences) {
		edges += createEdges(method.name, controlDependences[method].graph, "solid", "blue");
		boxes += createBoxes(method);
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}