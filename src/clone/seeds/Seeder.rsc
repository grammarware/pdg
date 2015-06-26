module clone::seeds::Seeder

import Prelude;
import analysis::graphs::Graph;

import clone::seeds::Config;
import clone::DataStructures;

import graph::DataStructures;
import graph::call::CallGraph;
import graph::factory::GraphFactory;


public Seeds generateSeeds(Projects projects) {
	CallGraph firstCallGraph = createCG(projects.first.model, projects.first.location);
	CallGraph secondCallGraph = createCG(projects.second.model, projects.second.location);
	
	Seeds seeds = {};
	
	for(method <- firstCallGraph.methodCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		loc firstLoc = firstCallGraph.locations[method];
		
		if(/^\$/ := firstLoc.parent.file) {
			continue;
		}
		
		loc secondLoc = secondCallGraph.locations[method];
		
		if(isEligible(method, firstCallGraph, secondCallGraph)) {
			Candidate firstCandidate = Candidate(EmptySD(projects.first.model, firstLoc), <{}, {}>, (), {});
			Candidate secondCandidate = Candidate(EmptySD(projects.second.model, secondLoc), <{}, {}>, (), {});
			
			seeds += <firstCandidate, secondCandidate>;
		}
	}
	
	return seeds;
}

private bool inScope(CallGraph callGraph, str file, str method) {
	if(SCOPE_FILTER) {
		return callGraph.methodFileMapping[file] == callGraph.methodFileMapping[method];
	}
	
	return true;
}

private set[str] getReachables(CallGraph callGraph, set[str] baseNodes, set[str] history) {
	if(isEmpty(baseNodes)) {
		return {};
	}
	
	set[str] reachables = {};
	
	for(base <- baseNodes, call <- callGraph.methodCalls[base], call notin history, call != base) {
		if(inScope(callGraph, base, call)) {
			reachables += { call };
		}
	}
	
	return baseNodes + reachables + getReachables(callGraph, reachables, history + baseNodes);
}

private bool isEligible(str origin, CallGraph firstCallGraph, CallGraph secondCallGraph) {
	set[str] firstCalls = { call | call <- firstCallGraph.methodCalls[origin], inScope(firstCallGraph, origin, call) };
	set[str] secondCalls = { call | call <- secondCallGraph.methodCalls[origin], inScope(secondCallGraph, origin, call) };
	
	if(firstCalls == secondCalls) {
		return false;
	}
	
	if(REACH_FILTER) {
		set[str] firstReachables = getReachables(firstCallGraph, { origin }, {});
		set[str] secondReachables = getReachables(secondCallGraph, { origin }, {});
		
		if(size(firstReachables) == 1 && size(secondReachables) == 1
			|| size(firstReachables) == size(secondReachables)) {
			return false;
		}
	}
	
	return true;
}