module screen::PostDominatorScreen

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
		displayPostDominatorTree(|project://JavaTest|, "testPDT");
		displayPostDominatorTree(|project://JavaTest|, "testPDT2");
		displayPostDominatorTree(|project://JavaTest|, "testCDG");
}
public void displayPostDominatorTree(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	PostDominators postDominators = createPostDominators(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- postDominators) {
		edges += createEdges(method.name, postDominators[method].tree, "solid", "blue");
		boxes += createBoxes(method);
		boxes += box(text("START <method.name>"), id("<method.name>:<STARTNODE>"), size(50), fillColor("lightblue"));
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

public void displayPostDominatorTree(loc project, str methodName, str fileName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, fileName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	PostDominators postDominators = createPostDominators(methodLocation, methodAST, projectModel, Intra());
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- postDominators) {
		edges += createEdges(method.name, postDominators[method].tree, "solid", "blue");
		boxes += createBoxes(method);
		boxes += box(text("START <method.name>"), id("<method.name>:<STARTNODE>"), size(50), fillColor("lightblue"));
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}