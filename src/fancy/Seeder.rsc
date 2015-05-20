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

data InternalSeed = InternalSeed(MethodData methodData, ProgramDependence programDependence, int identifier);

alias InitialSeeds = rel[set[loc], set[loc]];
alias MethodSeeds = rel[ProgramDependences, ProgramDependences];
alias MethodSeed = tuple[ProgramDependences, ProgramDependences];
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

public bool match(MethodData firstMethod, int seed1, MethodData secondMethod, int seed2) {	
	if(seed1 >= 0 && seed2 >= 0) {
		node firstStatement = resolveIdentifier(firstMethod, seed1);
		node secondStatement = resolveIdentifier(secondMethod, seed2);
		
		if(firstStatement == secondStatement) {
			println("=== MATCH === \n\t <firstStatement@src> \n\t <secondStatement@src>");
			return true;
		}
	} else {
		return seed1 == seed2;
	}
	
	return false;
}

public void prs(MethodData firstMethod, Graph[int] cd1, set[int] firstMatchSet, set[int] p1,
				 MethodData secondMethod, Graph[int] cd2, set[int] secondMatchSet, set[int] p2) {	
	for(match1 <- firstMatchSet, match2 <- secondMatchSet) {
		p1 += { match1 };
		p2 += { match2 };
		
		if(match(firstMethod, match1, secondMethod, match2)) {
			prs(firstMethod, cd1, successors(cd1, match1), p1, secondMethod, cd2, successors(cd2, match2), p2);
		}
	}
}

public void magic(GraphSeeds graphSeeds) {
	for(methodSeed <- graphSeeds) {
		for(<firstSeed, secondSeed> <- graphSeeds[methodSeed]) {
			Graph[int] cd1 = firstSeed.programDependence.controlDependence;
			Graph[int] cd2 = secondSeed.programDependence.controlDependence;
			
			set[int] p1 = { firstSeed.identifier };
			set[int] p2 = { secondSeed.identifier };
			
			set[int] firstMatchSet = predecessors(cd1, firstSeed.identifier);
			set[int] secondMatchSet = predecessors(cd2, secondSeed.identifier);
			
			//println(resolveIdentifier(firstSeed.methodData, firstSeed.identifier)@src);
			//println("Look at node <firstSeed.identifier> in <firstSeed.programDependence>.");
						
			//println(resolveIdentifier(secondSeed.methodData, secondSeed.identifier)@src);
			//println("Look at node <secondSeed.identifier> in <secondSeed.programDependence>.");
			
			prs(firstSeed.methodData, cd1, firstMatchSet, p1, secondSeed.methodData, cd2, secondMatchSet, p2);
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
					? statements[statement] + { InternalSeed(methodData, first[methodData], identifier) } 
					: { InternalSeed(methodData, first[methodData], identifier) };
			}
		}
		
		for(methodData <- second) {
			for(identifier <- environmentDomain(methodData)) {
				node statement = resolveIdentifier(methodData, identifier);
				
				if(statement in statements) {
					statementSeeds += statements[statement] * { InternalSeed(methodData, second[methodData], identifier) };
				}
			}
		}
		
		graphSeeds[pdgPair] = statementSeeds;
	}
	
	return graphSeeds;
}