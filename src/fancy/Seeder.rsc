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


public Seeds generateSeeds(Projects projects) {
	CallGraph firstCallGraph = createCG(projects.first.model, projects.first.location);
	CallGraph secondCallGraph = createCG(projects.second.model, projects.second.location);
	
	Seeds seeds = {};
	
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
		
		if(isEligible(method, firstCallGraph, secondCallGraph)) {
			Candidate firstCandidate = Candidate(EmptySD(projects.first.model, firstLoc), <{}, {}>, ());
			Candidate secondCandidate = Candidate(EmptySD(projects.second.model, secondLoc), <{}, {}>, ());
			
			seeds += <firstCandidate, secondCandidate>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

private bool sameFile(str file, str method) {
	if(/^<name:.*>:.*/ := method) {
		return file == name;
	}
	
	return false;
}

private bool isEligible(str origin, CallGraph firstCallGraph, CallGraph secondCallGraph) {
	str originName = "";
	
	if(/^<name:.*>:.*/ := origin) {
		originName = name;
	}
	
	set[str] firstCalls = { call | call <- firstCallGraph.methodCalls[origin], sameFile(originName, call) };
	set[str] secondCalls = { call | call <- secondCallGraph.methodCalls[origin], sameFile(originName, call) };
		
	if(firstCalls == secondCalls) {
		return false;
	}
	
	return true;
}