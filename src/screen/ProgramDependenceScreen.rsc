module screen::ProgramDependenceScreen

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

import creator::CFGCreator;
import graph::DataStructures;
import graph::\data::DDG;
import graph::control::PDT;
import graph::control::dependence::CDG;

@doc { 
	To run a test:
		displayProgramDependenceGraph(|project://JavaTest|, "main");
		displayProgramDependenceGraph(|project://pdg-JavaTest|, "testPDG");
		displayProgramDependenceGraph(|project://pdg-JavaTest|, "testPDT2");
}
public void displayProgramDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
		
	MethodData methodData = emptyMethodData();
	methodData.name = methodName;
	methodData.abstractTree = methodAST;
	
	list[MethodData] methodCollection = createControlFlows(methodLocation, methodData, projectModel);
	methodCollection = [ createPDT(method) | method <- methodCollection ];
	methodCollection = [ createCDG(method) | method <- methodCollection ];
	methodCollection = [ createDDG(method) | method <- methodCollection ];
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- methodCollection) {
		edges += createEdges(method.name, method.controlDependence.graph, "solid", "blue");
		edges += createEdges(method.name, method.dataDependence.graph, "dash", "green");
		
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}