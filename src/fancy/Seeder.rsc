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

alias InitialSeeds = rel[loc, loc];
alias MethodSeeds = rel[ProgramDependences, ProgramDependences];
alias MethodSeed = tuple[ProgramDependences first, ProgramDependences second];
alias StatementSeeds = rel[int, int];
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
		println(methodSeed.first);
		println(methodSeed.second);
		
		for(<firstSeed, secondSeed> <- graphSeeds[methodSeed]) {
			println(graphSeeds[methodSeed]);
			for(methodData <- methodSeed.first) {
				println(resolveIdentifier(methodData, firstSeed)@src);
			}
			
			for(methodData <- methodSeed.second) {
				println(resolveIdentifier(methodData, secondSeed)@src);
			}
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
			loc firstLoc = firstCallGraph.locations[method];
			loc secondLoc = secondCallGraph.locations[method];
			
			seeds += <firstLoc, secondLoc>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

public ProgramDependences getProgramDependences(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createProgramDependences(methodLocation, methodAST, projectModel, false);
}

public GraphSeeds detectGraphSeeds(MethodSeeds methodSeeds) {
	map[node, set[int]] statements = ();
	StatementSeeds statementSeeds = {};
	GraphSeeds graphSeeds = ();
	
	for(pdgPair: <first, second> <- methodSeeds) {
		statements = ();
		statementSeeds = {};
		
		for(methodData <- first) {
			for(identifier <- environmentDomain(methodData)) {
				println("First <methodData.name>: <identifier>");
				node statement = resolveIdentifier(methodData, identifier);
				statements[statement] = statement in statements ? statements[statement] + { identifier } : { identifier };
			}
		}
		
		println(second);
		
		for(methodData <- second) {
			println(environmentDomain(methodData));
			for(identifier <- environmentDomain(methodData)) {
				node statement = resolveIdentifier(methodData, identifier);
				
				if(statement in statements) {
					println(statements[statement]);
					println("Second <methodData.name>: <identifier>");
					statementSeeds += statements[statement] * { identifier };
				}
			}
		}
		
		graphSeeds[pdgPair] = statementSeeds;
	}
	
	return graphSeeds;
}