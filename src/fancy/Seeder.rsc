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
import graph::factory::GraphFactory;

public rel[set[loc], set[loc]] generateSeeds(str firstProject, str secondProject) {
	M3 firstModel = createM3(|project://<firstProject>|);
	CallGraph firstCallGraph = createCG(firstModel, |project://<firstProject>|);
	
	M3 secondModel = createM3(|project://<secondProject>|);
	CallGraph secondCallGraph = createCG(secondModel, |project://<secondProject>|);
	
	rel[set[loc], set[loc]] seeds = generateInitialSeeds(firstCallGraph, secondCallGraph);
	rel[ProgramDependences, ProgramDependences] pdgSeeds = {};
	
	for(<first, second> <- seeds) {
		pdgSeeds += <getProgramDependences(firstModel, first), getProgramDependences(secondModel, second)>;
	}
	
	detectMethodSeeds(pdgSeeds);
	
	return seeds;
}

public rel[set[loc], set[loc]] generateInitialSeeds(CallGraph firstCallGraph, CallGraph secondCallGraph) {
	rel[set[loc], set[loc]] seeds = {};
	
	int seedAmount = 1;
	
	for(method <- firstCallGraph.methodCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		set[str] firstCalls = firstCallGraph.methodCalls[method];
		set[str] secondCalls = secondCallGraph.methodCalls[method];
		
		if(firstCalls != secondCalls) {
			set[loc] firstLocs = { firstCallGraph.locations[method] };
			set[loc] secondLocs = { secondCallGraph.locations[method] };
			
			if(size(firstCalls) > size(secondCalls)) {
				firstLocs += { firstCallGraph.locations[location] | location <- firstCalls - secondCalls };
			} else {
				secondLocs += { secondCallGraph.locations[location] | location <- secondCalls - firstCalls };
			}
			
			seeds += <firstLocs, secondLocs>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

public ProgramDependences getProgramDependences(M3 projectModel, set[loc] methodLocations) {
	ProgramDependences programDependences = ();
	node methodAST;
	
	for(methodLocation <- methodLocations) {
		methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
		ProgramDependences createdPD = createProgramDependences(methodLocation, methodAST, projectModel, false);
		
		for(methodData <- createdPD) {
			programDependences[methodData] = createdPD[methodData];
		}
	}
	
	return programDependences;
}

public set[rel[loc, loc]] detectMethodSeeds(rel[ProgramDependences, ProgramDependences] pdgSeeds) {
	map[node, set[loc]] locs = ();
	rel[loc, loc] methodSeeds = {};
	set[rel[loc, loc]] pdgMethodSeeds = {};
	
	for(<first, second> <- pdgSeeds) {
		for(methodData <- first) {
			for(n <- range(methodData.nodeEnvironment)) {
				locs[n] = n in locs ? locs[n] + { n@src } : { n@src };
			}
		}
		
		for(methodData <- second) {
			for(n <- range(methodData.nodeEnvironment)) {
				if(n in locs) {
					methodSeeds += locs[n] * { n@src };
				}
			}
		}
		
		pdgMethodSeeds += { methodSeeds };
	}
	
	return pdgMethodSeeds;
}