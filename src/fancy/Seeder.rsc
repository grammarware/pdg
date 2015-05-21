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

alias InitialSeeds = rel[loc, loc];
alias MethodSeeds = rel[SystemDependence, SystemDependence];

public InitialSeeds generateSeeds(str firstProject, str secondProject) {
	M3 firstModel = createM3(|project://<firstProject>|);
	CallGraph firstCallGraph = createCG(firstModel, |project://<firstProject>|);
	
	M3 secondModel = createM3(|project://<secondProject>|);
	CallGraph secondCallGraph = createCG(secondModel, |project://<secondProject>|);
	
	InitialSeeds seeds = generateInitialSeeds(firstCallGraph, secondCallGraph);
	MethodSeeds methodSeeds = {
		<getSystemDependence(firstModel, first), getSystemDependence(secondModel, second)>
		| <first, second> <- seeds
	};
	
	magic(methodSeeds);
	
	return seeds;
}

private str getNodeName(node treeNode) {
	if(/^<name:\w*>/ := "<treeNode>") {
		return name;
	}
	
	return "<treeNode>";
}

public bool match(map[str, node] firstEnv, str seed1, map[str, node] secondEnv, str seed2) {	
	node firstStatement = firstEnv[seed1];
	node secondStatement = secondEnv[seed2];
	
	if(getNodeName(firstStatement) == getNodeName(secondStatement)) {
		println("=== MATCH === \n\t <firstStatement@src> \n\t <secondStatement@src>");
		return true;
	}
	
	return false;
}

public set[str] nextFrontier(map[str, node] environment, Graph[str] graph, str startNode) {
	 set[str] frontier = successors(graph, startNode);
	 
	 for(frontNode <- frontier) {
	 	if(frontNode in environment && environment[frontNode] != Normal()
	 		|| frontNode notin environment)
	 		frontier += nextFrontier(environment, graph, frontNode);
	 }
	 
	 frontier = { frontNode | frontNode <- frontier, frontNode in environment, environment[frontNode]@nodeType == Normal() };
	 
	 return frontier;
}

public void prs(map[str, node] firstEnv, Graph[str] cd1, set[str] firstMatchSet,
				 map[str, node] secondEnv, Graph[str] cd2, set[str] secondMatchSet) {	
	for(match1 <- firstMatchSet, match2 <- secondMatchSet) {
		match(firstEnv, match1, secondEnv, match2);
		
		prs(firstEnv, cd1, nextFrontier(firstEnv, cd1, match1), secondEnv, cd2, nextFrontier(secondEnv, cd2, match2));
	}
}

public void magic(MethodSeeds methodSeeds) {
	for(<firstSDG, secondSDG>  <- methodSeeds) {
		Graph[str] cd1 = firstSDG.controlDependence + firstSDG.iControlDependence;
		Graph[str] cd2 = secondSDG.controlDependence + secondSDG.iControlDependence;
		
		set[str] firstMatchSet = successors(cd1, getOneFrom(top(cd1)));
		set[str] secondMatchSet = successors(cd2, getOneFrom(top(cd2)));
		
		prs(firstSDG.nodeEnvironment, cd1, firstMatchSet, secondSDG.nodeEnvironment, cd2, secondMatchSet);
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

public SystemDependence getSystemDependence(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createSystemDependence(methodLocation, methodAST, projectModel, File());
}