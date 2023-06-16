@contributor{René Bulsing - UvA MSc 2015}
module graph::factory::GraphFactory

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import analysis::graphs::Graph;

import extractors::Project;
import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;
import graph::control::dependence::CDG;
import graph::\data::DDG;
import graph::program::PDG;
import graph::system::SDG;

private int MAXDEPTH = 100;
data Scope = Intra() | File() | Project();

private set[loc] generatedMethods = {};

private map[MethodData, ControlFlow] getCalledMethods(loc origin, set[loc] calledMethods, M3 projectModel, Scope scope, int depth) {
	map[MethodData, ControlFlow] methodCollection = ();
	node methodAST;
	GeneratedData generatedData;
	MethodData methodData;
	ControlFlow controlFlow;
	
	calledMethods = filterCalledMethods(origin, calledMethods, scope);
	
	for(calledMethod <- calledMethods, calledMethod notin generatedMethods) {
		methodAST = getMethodASTEclipse(calledMethod, model = projectModel);
		generatedData = createCFG(projectModel, cast(#Declaration, methodAST));
		
		if(generatedData == EmptyGD()) {
			continue;
		}
		
		methodData = generatedData.methodData;
		methodData.callSites = filterCallSites(calledMethod, methodData, scope);
		
		controlFlow = generatedData.controlFlow;
		methodCollection[methodData] = controlFlow;
		
		generatedMethods += calledMethod;
		
		if(depth < MAXDEPTH) {
			methodCollection += getCalledMethods(origin, methodData.calledMethods, projectModel, scope, depth + 1);
		}
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
	GeneratedData generatedData = createCFG(projectModel, cast(#Declaration, abstractTree));
	
	if(generatedData == EmptyGD()) {
		return ();
	}
	
	MethodData methodData = generatedData.methodData;
	methodData.callSites = filterCallSites(methodLocation, methodData, scope);
	
	ControlFlow controlFlow = generatedData.controlFlow;
	
	map[MethodData, ControlFlow] controlFlows = ( methodData : controlFlow );
	
	generatedMethods = { methodLocation };
	
	controlFlows += getCalledMethods(methodLocation, methodData.calledMethods, projectModel, scope, 0);
	
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
	
	return createSDG(projectModel, controlDependences, dataDependences);
}