module graph::factory::GraphFactory

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import extractors::Project;
import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;
import graph::control::dependence::CDG;
import graph::\data::DDG;
import graph::program::PDG;


private set[loc] generatedMethods = {};

private map[MethodData, ControlFlow] getCalledMethods(set[loc] calledMethods, M3 projectModel) {
	map[MethodData, ControlFlow] methodCollection = ();
	node methodAST;
	GeneratedData generatedData;
	MethodData methodData;
	ControlFlow controlFlow;
	
	for(calledMethod <- calledMethods, calledMethod notin generatedMethods) {
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

public ControlFlows createControlFlows(loc methodLocation, node abstractTree, M3 projectModel, bool includeCalls) {
	GeneratedData generatedData = createCFG(cast(#Declaration, abstractTree));
	
	MethodData methodData = generatedData.methodData;
	ControlFlow controlFlow = generatedData.controlFlow;
	
	map[MethodData, ControlFlow] controlFlows = ( methodData : controlFlow );
	
	generatedMethods = { methodLocation };
	
	if(includeCalls) {
		controlFlows += getCalledMethods(methodData.calledMethods, projectModel);
	}
	
	return controlFlows;
}

public PostDominators createPostDominators(loc methodLocation, node abstractTree, M3 projectModel, bool includeCalls) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, includeCalls);
	return ( method : createPDT(method, controlFlows[method]) | method <- controlFlows );
}

public ControlDependences createControlDependences(loc methodLocation, node abstractTree, M3 projectModel, bool includeCalls) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, includeCalls);
	PostDominators postDominators = createPostDominators(methodLocation, abstractTree, projectModel, includeCalls);
	return ( 
		method : createCDG(method, controlFlows[method], postDominators[method]) 
		| method <- postDominators 
	);
}

public DataDependences createDataDependences(loc methodLocation, node abstractTree, M3 projectModel, bool includeCalls) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, includeCalls);
	return ( method : createDDG(method, controlFlows[method]) | method <- controlFlows );
}

public ProgramDependences createProgramDependences(loc methodLocation, node abstractTree, M3 projectModel, bool includeCalls) {
	ControlDependences controlDependences = createControlDependences(methodLocation, abstractTree, projectModel, includeCalls);
	DataDependences dataDependences = createDataDependences(methodLocation, abstractTree, projectModel, includeCalls);
	
	return ( method : createPDG(controlDependences[method], dataDependences[method]) 
			| method <- controlDependences
		 	);
}