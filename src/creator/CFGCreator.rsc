module creator::CFGCreator

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import graph::DataStructures;
import extractors::Project;
import graph::control::flow::CFG;

set[loc] generatedMethods = {};

public list[MethodData] createControlFlows(loc methodLocation, MethodData methodData, M3 projectModel) {
	methodData = createCFG(methodData);
	
	generatedMethods = { methodLocation };
	
	list[MethodData] methodCollection = [methodData];
	methodCollection += getCalledMethods(methodData.calledMethods, projectModel);	
	
	return methodCollection;
}

private str extractMethodName(loc methodLocation) {
	if(/<name:.*>\(/ := methodLocation.file) {
		return name;
	}
	
	return "";
}

private list[MethodData] getCalledMethods(set[loc] calledMethods, M3 projectModel) {
	list[MethodData] methodCollection = [];
	MethodData methodData = emptyMethodData();
	
	for(calledMethod <- calledMethods, calledMethod in getM3Methods(projectModel), calledMethod notin generatedMethods) {
		methodData.name = extractMethodName(calledMethod);
		methodData.abstractTree = getMethodASTEclipse(calledMethod, model = projectModel);
		methodData = createCFG(methodData);
		
		methodCollection += methodData;
		generatedMethods += calledMethod;
		
		methodCollection += getCalledMethods(methodData.calledMethods, projectModel);
	}
	
	return methodCollection;
}