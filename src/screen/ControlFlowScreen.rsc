module screen::ControlFlowScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import graph::DataStructures;
import extractors::Project;
import graph::control::flow::CFG;

set[loc] generatedMethods = {};

@doc { 
	To run a test:
		displayControlFlowGraph(|project://pdg-JavaTest|, "testCDG");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	MethodData methodData = emptyMethodData();
	methodData.name = methodName;
	methodData.abstractTree = methodAST;
	methodData = createCFG(methodData, 0);
	
	int maxIdentifier = max(environmentDomain(methodData)) + 1;
	list[MethodData] methodCollection = [methodData];
	
	generatedMethods = { methodLocation };
	methodCollection += getCalledMethods(methodData.calledMethods, maxIdentifier, projectModel);	
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	for(method <- methodCollection) {
		edges += createEdges(method.controlFlow);
		boxes += createBoxes(method);
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}


private list[MethodData] getCalledMethods(set[loc] calledMethods, int startIdentifier, M3 projectModel) {
	int maxIdentifier = startIdentifier;
	list[MethodData] methodCollection = [];
	
	MethodData methodData = emptyMethodData();
	
	for(calledMethod <- calledMethods, calledMethod in getM3Methods(projectModel), calledMethod notin generatedMethods) {
		methodData.abstractTree = getMethodASTEclipse(calledMethod, model = projectModel);
		
		methodData = createCFG(methodData, maxIdentifier);
		methodCollection += methodData;
		generatedMethods += calledMethod;
		
		maxIdentifier = max(environmentDomain(methodData)) + 1;
		methodCollection += getCalledMethods(methodData.calledMethods, maxIdentifier, projectModel);
	}
	
	return methodCollection;
}

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	return |file://methodDoesNotExist|;
}

private list[Edge] createEdges(ControlFlow controlFlow) {
	list[Edge] edges = [];

	for(graphEdge <- controlFlow.graph) {
		edges += edge("<graphEdge.from>", "<graphEdge.to>", toArrow(box(size(10), fillColor("black"))));
	}
	
	return edges;
}

private Figures createBoxes(MethodData methodData) {
	Figures boxes = [];
	
	for(treeNode <- environmentDomain(methodData)) {
		boxes += box(text("<treeNode>: <nodeName(methodData, treeNode)>"), id("<treeNode>"), size(50), fillColor("lightgreen"));
	}
	
	return boxes;
}