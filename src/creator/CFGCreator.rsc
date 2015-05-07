module creator::CFGCreator

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import graph::DataStructures;
import extractors::Project;
import graph::control::flow::CFG;

set[loc] generatedMethods = {};

public map[MethodData, ControlFlow] createControlFlows(loc methodLocation, node abstractTree, M3 projectModel) {
	GeneratedData generatedData = createCFG(cast(#Declaration, abstractTree));
	
	MethodData methodData = generatedData.methodData;
	ControlFlow controlFlow = generatedData.controlFlow;
	
	map[MethodData, ControlFlow] controlFlows = ( methodData : controlFlow );
	
	generatedMethods = { methodLocation };
	controlFlows += getCalledMethods(methodData.calledMethods, projectModel);	
	
	return controlFlows;
}

private map[MethodData, ControlFlow] getCalledMethods(set[loc] calledMethods, M3 projectModel) {
	map[MethodData, ControlFlow] methodCollection = ();
	node methodAST;
	GeneratedData generatedData;
	MethodData methodData;
	ControlFlow controlFlow;
	
	for(calledMethod <- calledMethods, calledMethod in getM3Methods(projectModel), calledMethod notin generatedMethods) {
		methodAST = getMethodASTEclipse(calledMethod, model = projectModel);
		generatedData = createCFG(cast(#Declaration, methodAST));
		
		methodData = generatedData.methodData;
		controlFlow = generatedData.controlFlow;
		methodCollection[methodData] = controlFlow;
		
		generatedMethods += calledMethod;
		methodCollection += getCalledMethods(methodData.calledMethods, projectModel);
	}
	
	return methodCollection;
}