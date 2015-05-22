module fancy::Seeder

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import fancy::Matcher;
import fancy::DataStructures;
import extractors::Project;
import graph::DataStructures;
import graph::call::CallGraph;
import graph::factory::GraphFactory;

data InternalSeed = InternalSeed(MethodData methodData, ProgramDependence programDependence, int identifier);

public InitialSeeds generateSeeds(str firstProject, str secondProject) {
	loc firstProjectLoc = |project://<firstProject>|;
	M3 firstModel = createM3(firstProjectLoc);
	CallGraph firstCallGraph = createCG(firstModel, firstProjectLoc);
	
	loc secondProjectLoc = |project://<secondProject>|;
	M3 secondModel = createM3(secondProjectLoc);
	CallGraph secondCallGraph = createCG(secondModel, secondProjectLoc);
	
	InitialSeeds seeds = generateInitialSeeds(firstCallGraph, secondCallGraph);
	MethodSeeds methodSeeds = {
		<getSystemDependence(firstModel, first), getSystemDependence(secondModel, second)>
		| <first, second> <- seeds
	};
	
	magic(methodSeeds);
	
	unregisterProject(firstProjectLoc);
	unregisterProject(secondProjectLoc);
	
	return seeds;
}

public InitialSeeds generateInitialSeeds(CallGraph firstCallGraph, CallGraph secondCallGraph) {
	InitialSeeds seeds = {};
	
	int seedAmount = 1;
	
	for(method <- firstCallGraph.methodCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		loc firstLoc = firstCallGraph.locations[method];
		
		if(/^\$/ := firstLoc.parent.file) {
			continue;
		}
		
		loc secondLoc = secondCallGraph.locations[method];
		
		set[str] firstCalls = firstCallGraph.methodCalls[method];
		set[str] secondCalls = secondCallGraph.methodCalls[method];
		
		if(firstCalls != secondCalls) {
			seeds += <firstLoc, secondLoc>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

public SystemDependence getSystemDependence(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createSystemDependence(methodLocation, methodAST, projectModel, File());
}