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
		
		set[str] firstCalls = firstCallGraph.methodCalls[method];
		set[str] secondCalls = secondCallGraph.methodCalls[method];
		
		if(isEligible(method, firstCalls, secondCalls)) {
			Candidate firstCandidate = Candidate(EmptySD(projects.first.model, firstLoc), <{}, {}>, ());
			Candidate secondCandidate = Candidate(EmptySD(projects.second.model, secondLoc), <{}, {}>, ());
			
			seeds += <firstCandidate, secondCandidate>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

private bool isEligible(str origin, set[str] firstCalls, set[str] secondCalls) {
	if(firstCalls == secondCalls) {
		return false;
	}
	
	set[str] difference = size(firstCalls) > size(secondCalls) ? firstCalls - secondCalls : secondCalls - firstCalls;
	
	str originName = "";
	
	if(/^<name:.*>:.*/ := origin) {
		originName = name;
	}
	
	for(n <- difference, /^<name:.*>:.*/ := n) {
		if(originName == name) {
			return true;
		}
	}
	
	return false;
}