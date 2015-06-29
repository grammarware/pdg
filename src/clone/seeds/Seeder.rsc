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
	set[CallVertex] coveredCalls = {};
	
	for(methodCall <- firstCallGraph.methodCalls) {
		if(methodCall notin secondCallGraph.methodCalls) {
			continue;
		}
		
		set[CallVertex] firstMethods = firstCallGraph.locations[methodCall.identifier];
		
		for(callVertex <- firstMethods) {
			if(isEligible(callVertex, firstCallGraph, secondCallGraph)) {
				Candidate firstCandidate = Candidate(|unknown:///|
						, EmptySD(projects.first.model, callVertex.location), <{}, {}>, (), {});
				Candidate secondCandidate = Candidate(|unknown:///|
						, EmptySD(projects.second.model, callVertex.location), <{}, {}>, (), {});
				
				seeds += <firstCandidate, secondCandidate>;
			}
		}
	}
	
	return seeds;
}

private bool inScope(CallGraph callGraph, CallVertex origin, CallVertex called) {
	if(SCOPE_FILTER) {
		return callGraph.methodFileMapping[origin.identifier] == callGraph.methodFileMapping[called.identifier];
	}
	
	return true;
}

private set[CallVertex] getReachables(CallGraph callGraph, set[CallVertex] baseNodes, set[CallVertex] history) {
	if(isEmpty(baseNodes)) {
		return {};
	}
	
	set[CallVertex] reachables = {};
	
	for(base <- baseNodes, call <- callGraph.methodCalls[base], call notin history, call != base) {
		if(inScope(callGraph, base, call)) {
			reachables += { call };
		}
	}
	
	return baseNodes + reachables + getReachables(callGraph, reachables, history + baseNodes);
}

private bool isEligible(CallVertex origin, CallGraph firstCallGraph, CallGraph secondCallGraph) {
	if(origin notin secondCallGraph.methodCalls) {
		return false;
	}
	
	set[CallVertex] firstCalls = { call | call <- firstCallGraph.methodCalls[origin], inScope(firstCallGraph, origin, call) };
	set[CallVertex] secondCalls = { call | call <- secondCallGraph.methodCalls[origin], inScope(secondCallGraph, origin, call) };
	
	if(firstCalls == secondCalls) {
		return false;
	}
	
	if(REACH_FILTER) {
		set[CallVertex] firstReachables = getReachables(firstCallGraph, { origin }, {});
		set[CallVertex] secondReachables = getReachables(secondCallGraph, { origin }, {});
		
		if(size(firstReachables) == 1 && size(secondReachables) == 1
			|| size(firstReachables) == size(secondReachables)) {
			return false;
		}
	}
	
	return true;
}