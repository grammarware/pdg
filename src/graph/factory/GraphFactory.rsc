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
import graph::system::SDG;

data Scope = Intra() | File() | Project();

private set[loc] generatedMethods = {};

private map[MethodData, ControlFlow] getCalledMethods(loc origin, set[loc] calledMethods, M3 projectModel, Scope scope) {
	map[MethodData, ControlFlow] methodCollection = ();
	node methodAST;
	GeneratedData generatedData;
	MethodData methodData;
	ControlFlow controlFlow;
	
	calledMethods = filterCalledMethods(origin, calledMethods, scope);
	
	for(calledMethod <- calledMethods, calledMethod notin generatedMethods) {
		methodAST = getMethodASTEclipse(calledMethod, model = projectModel);
		generatedData = createCFG(cast(#Declaration, methodAST));
		
		if(generatedData == EmptyGD()) {
			continue;
		}
		
		methodData = generatedData.methodData;
		methodData.callSites = filterCallSites(calledMethod, methodData, scope);
		
		controlFlow = generatedData.controlFlow;
		methodCollection[methodData] = controlFlow;
		
		generatedMethods += calledMethod;
		
		methodCollection += getCalledMethods(origin, methodData.calledMethods, projectModel, scope);
	}
	
	return methodCollection;
}

public set[loc] filterCalledMethods(loc origin, set[loc] calledMethods, Intra()) {
	return {};
}

public set[loc] filterCalledMethods(loc origin, set[loc] calledMethods, File()) {
 	return { calledMethod | calledMethod <- calledMethods, calledMethod.parent.file == origin.parent.file };
}

public set[loc] filterCalledMethods(loc origin, set[loc] calledMethods, Project()) {
	return calledMethods;
}

public set[int] filterCallSites(loc origin, MethodData methodData, Intra()) {
	return {};
}

public set[int] filterCallSites(loc origin, MethodData methodData, File()) {
 	return { callSite | callSite <- methodData.callSites, origin.parent.file == resolveIdentifier(methodData, callSite)@decl.parent.file };
}

public set[int] filterCallSites(loc origin, MethodData methodData, Project()) {
	return methodData.callSites;
}

public ControlFlows createControlFlows(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	GeneratedData generatedData = createCFG(cast(#Declaration, abstractTree));
	
	MethodData methodData = generatedData.methodData;
	methodData.callSites = filterCallSites(methodLocation, methodData, scope);
	
	ControlFlow controlFlow = generatedData.controlFlow;
	
	map[MethodData, ControlFlow] controlFlows = ( methodData : controlFlow );
	
	generatedMethods = { methodLocation };
	
	controlFlows += getCalledMethods(methodLocation, methodData.calledMethods, projectModel, scope);
	
	return controlFlows;
}

public PostDominators createPostDominators(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, scope);
	return ( method : createPDT(method, controlFlows[method]) | method <- controlFlows );
}

public ControlDependences createControlDependences(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, scope);
	PostDominators postDominators = createPostDominators(methodLocation, abstractTree, projectModel, scope);
	return ( 
		method : createCDG(method, controlFlows[method], postDominators[method]) 
		| method <- postDominators 
	);
}

public DataDependences createDataDependences(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	ControlFlows controlFlows = createControlFlows(methodLocation, abstractTree, projectModel, scope);
	return ( method : createDDG(method, controlFlows[method]) | method <- controlFlows );
}

public ProgramDependences createProgramDependences(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	ControlDependences controlDependences = createControlDependences(methodLocation, abstractTree, projectModel, scope);
	DataDependences dataDependences = createDataDependences(methodLocation, abstractTree, projectModel, scope);
	
	return ( method : createPDG(controlDependences[method], dataDependences[method]) 
			| method <- controlDependences
		 	);
}

public SystemDependence createSystemDependence(loc methodLocation, node abstractTree, M3 projectModel, Scope scope) {
	ControlDependences controlDependences = createControlDependences(methodLocation, abstractTree, projectModel, scope);
	DataDependences dataDependences = createDataDependences(methodLocation, abstractTree, projectModel, scope);
	
	return createSDG(controlDependences, dataDependences);
}