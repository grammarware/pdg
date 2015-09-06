@contributor{Lulu Zhang - UvA MSc 2014}
@contributor{René Bulsing - UvA MSc 2015}
module screen::DataDependenceScreen

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
import graph::factory::GraphFactory;


@doc{ 
	To run a test:
		displayDataDependenceGraph(|project://JavaTest|, "testPDT");
		displayDataDependenceGraph(|project://JavaTest|, "testPDT2");
		displayDataDependenceGraph(|project://QL|, "nextToken");
}
public void displayDataDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	DataDependences dataDependences = createDataDependences(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- dataDependences) {
		edges += createEdges(method.name, dataDependences[method].graph, "dash", "green");
		boxes += createBoxes(method);
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}