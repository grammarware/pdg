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

private set[str] coveredCalls = {};

public Seeds generateSeeds(Projects projects) {
	CallGraph firstCallGraph = createCG(projects.first.model, projects.first.location);
	CallGraph secondCallGraph = createCG(projects.second.model, projects.second.location);
	
	coveredCalls = {};
	Seeds seeds = {};
	
	int seedAmount = 1;
	
	for(method <- firstCallGraph.methodCalls, method notin coveredCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		loc firstLoc = firstCallGraph.locations[method];
		
		if(/^\$/ := firstLoc.parent.file) {
			continue;
		}
		
		loc secondLoc = secondCallGraph.locations[method];
		
		if(isEligible(method, firstCallGraph, secondCallGraph)) {
			Candidate firstCandidate = Candidate(EmptySD(projects.first.model, firstLoc), <{}, {}>, ());
			Candidate secondCandidate = Candidate(EmptySD(projects.second.model, secondLoc), <{}, {}>, ());
			
			seeds += <firstCandidate, secondCandidate>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

private bool sameFile(CallGraph callGraph, str file, str method) {
	return callGraph.methodFileMapping[file] == callGraph.methodFileMapping[method];
}

private set[str] getReachables(CallGraph callGraph, set[str] baseNodes, set[str] history) {
	if(isEmpty(baseNodes)) {
		return {};
	}
	
	set[str] reachables = {};
	
	for(base <- baseNodes, call <- callGraph.methodCalls[base], call notin history, call != base) {
		if(sameFile(callGraph, base, call)) {
			reachables += { call };
		}
	}
	
	return baseNodes + reachables + getReachables(callGraph, reachables, history + baseNodes);
}

private bool isEligible(str origin, CallGraph firstCallGraph, CallGraph secondCallGraph) {
	set[str] firstCalls = { call | call <- firstCallGraph.methodCalls[origin], sameFile(firstCallGraph, origin, call) };
	set[str] allowedNodes = firstCallGraph.fileMethodsMapping[firstCallGraph.methodFileMapping[origin]];
	set[str] firstReachables = getReachables(firstCallGraph, { origin }, {});

	set[str] secondCalls = { call | call <- secondCallGraph.methodCalls[origin], sameFile(secondCallGraph, origin, call) };
	allowedNodes = secondCallGraph.fileMethodsMapping[secondCallGraph.methodFileMapping[origin]];
	set[str] secondReachables = getReachables(secondCallGraph, { origin }, {});
	
	coveredCalls += firstReachables;
	coveredCalls += secondReachables;
		
	if(firstCalls == secondCalls) {
		return false;
	}
	
	return true;
}