module fancy::Seeder

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import extractors::Project;
import graph::call::CallGraph;
import graph::DataStructures;

public rel[loc, loc] generateInitialSeeds(str firstProject, str secondProject) {
	rel[loc, loc] seeds = {};

	M3 projectModel = createM3(|project://<firstProject>|);
	CallGraph firstCallGraph = createCG(projectModel, |project://<firstProject>|);
	
	projectModel = createM3(|project://<secondProject>|);
	CallGraph secondCallGraph = createCG(projectModel, |project://<secondProject>|);
	
	int seedAmount = 1;
	
	for(method <- firstCallGraph.methodCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		if(firstCallGraph.methodCalls[method] != secondCallGraph.methodCalls[method]) {
			seeds += <firstCallGraph.locations[method], secondCallGraph.locations[method]>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}