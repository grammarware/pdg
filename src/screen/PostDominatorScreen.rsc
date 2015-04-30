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
import creator::CFGCreator;
import creator::PDTCreator;

@doc {
	To run a test:
		displayPostDominatorTree(|project://pdg-JavaTest|, "testPDT");
		displayPostDominatorTree(|project://pdg-JavaTest|, "testPDT2");
		displayPostDominatorTree(|project://pdg-JavaTest|, "testCDG");
}
public void displayPostDominatorTree(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	MethodData methodData = emptyMethodData();
	methodData.name = methodName;
	methodData.abstractTree = methodAST;
	
	list[MethodData] methodCollection = createControlFlows(methodLocation, methodData, projectModel);
	methodCollection = createPostDominators(methodCollection);
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- methodCollection) {
		edges += createEdges(method.name, method.postDominator.tree);
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
		boxes += box(text("START <method.name>"), id("<method.name>:<STARTNODE>"), size(50), fillColor("lightblue"));
		boxes += box(text("EXIT <method.name>"), id("<method.name>:<EXITNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}