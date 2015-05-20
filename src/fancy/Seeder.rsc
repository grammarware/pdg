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

data InternalSeed = InternalSeed(map[int, node] nodes, int identifier);

alias InitialSeeds = rel[set[loc], set[loc]];
alias MethodSeeds = rel[ProgramDependences, ProgramDependences];
alias MethodSeed = tuple[ProgramDependences first, ProgramDependences second];
alias StatementSeeds = rel[InternalSeed, InternalSeed];
alias GraphSeeds = map[MethodSeed, StatementSeeds];

public InitialSeeds generateSeeds(str firstProject, str secondProject) {
	M3 firstModel = createM3(|project://<firstProject>|);
	CallGraph firstCallGraph = createCG(firstModel, |project://<firstProject>|);
	
	M3 secondModel = createM3(|project://<secondProject>|);
	CallGraph secondCallGraph = createCG(secondModel, |project://<secondProject>|);
	
	InitialSeeds seeds = generateInitialSeeds(firstCallGraph, secondCallGraph);	
	MethodSeeds methodSeeds = {
		<getProgramDependences(firstModel, first), getProgramDependences(secondModel, second)>
		| <first, second> <- seeds
	};
	
	GraphSeeds graphSeeds = detectGraphSeeds(methodSeeds);
	
	magic(graphSeeds);
	
	return seeds;
}

public void magic(GraphSeeds graphSeeds) {
	for(methodSeed <- graphSeeds) {
		for(<firstSeed, secondSeed> <- graphSeeds[methodSeed]) {
			println(firstSeed.nodes[firstSeed.identifier]@src);
			println(secondSeed.nodes[secondSeed.identifier]@src);
		}
	}
}

public InitialSeeds generateInitialSeeds(CallGraph firstCallGraph, CallGraph secondCallGraph) {
	InitialSeeds seeds = {};
	
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

public GraphSeeds detectGraphSeeds(MethodSeeds methodSeeds) {
	map[node, set[InternalSeed]] statements = ();
	StatementSeeds statementSeeds = {};
	GraphSeeds graphSeeds = ();
	
	for(pdgPair: <first, second> <- methodSeeds) {
		statements = ();
		statementSeeds = {};
		
		for(methodData <- first) {
			for(identifier <- environmentDomain(methodData)) {
				node statement = resolveIdentifier(methodData, identifier);
				
				statements[statement] = statement in statements 
					? statements[statement] + { InternalSeed(methodData.nodeEnvironment, identifier) } 
					: { InternalSeed(methodData.nodeEnvironment, identifier) };
			}
		}
		
		for(methodData <- second) {
			for(identifier <- environmentDomain(methodData)) {
				node statement = resolveIdentifier(methodData, identifier);
				
				if(statement in statements) {
					statementSeeds += statements[statement] * { InternalSeed(methodData.nodeEnvironment, identifier) };
				}
			}
		}
		
		graphSeeds[pdgPair] = statementSeeds;
	}
	
	return graphSeeds;
}