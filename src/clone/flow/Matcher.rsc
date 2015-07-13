module clone::flow::Matcher

import Prelude;
import analysis::graphs::Graph;

import clone::flow::Creator;
import clone::flow::NodeStripper;
import clone::DataStructures;
import graph::DataStructures;


public Highlights addHighlights(Highlights highlights, map[Vertex, node] environment, Flow flow) {	
	loc file = environment[flow.root]@src;
	file.offset = 0;
	file.length = 0;
	file.begin.line = 0;
	file.begin.column = 0;
	file.end.line = 0;
	file.end.column = 0;
	
	if(file notin highlights) {
		highlights[file] = {};
	}

	highlights[file] += flow.lineNumbers;
	
	return highlights;
}

private Graph mergeDataGraphs(SystemDependence systemDependence) {
	return systemDependence.dataDependence 
			+ systemDependence.globalDataDependence 
			+ systemDependence.iDataDependence;
}

private Graph mergeControlGraphs(SystemDependence systemDependence) {
	return systemDependence.controlDependence 
			+ systemDependence.iControlDependence;
}

private set[Vertex] firstEncountered = {};
private set[Vertex] secondEncountered = {};

private rel[Flow, Flow] getMatch(Flow first, Flow second) {
	if(first.target in firstEncountered && second.target in secondEncountered) {
		return {};
	}
	
	firstEncountered += { first.root, first.target };
	secondEncountered += { second.root, second.target };
	
	return { <first, second> };
}

private rel[Flow, Flow] calculateMaximumMatch(SystemDependence firstSDG, SystemDependence secondSDG
												, set[Flow](&A, &B) frontierCalculator
												, rel[Flow, Flow] matchedFlows) {
	if(isEmpty(matchedFlows)) {
		return {};
	}
	
	set[Flow] firstFrontier = frontierCalculator(firstSDG, {flow.target | flow <- domain(matchedFlows)});
	set[Flow] secondFrontier = frontierCalculator(secondSDG, {flow.target | flow <- range(matchedFlows)});
	
	rel[Flow, Flow] newMatches = {
			*getMatch(firstFlow, secondFlow)
			| firstFlow <- firstFrontier
			, secondFlow <- secondFrontier
			, stripNode(firstSDG.nodeEnvironment[firstFlow.target]) == stripNode(secondSDG.nodeEnvironment[secondFlow.target])
		};
		
	return newMatches + calculateMaximumMatch(firstSDG, secondSDG, frontierCalculator, newMatches);
}

private CandidatePair matchFlows(CandidatePair candidatePair, Graph(SystemDependence) graphMerger, set[Flow](&A, &B) frontierCalculator) {
	firstEncountered = secondEncountered = {};
	
	Candidate firstCandidate = candidatePair.first;
	map[Vertex, node] firstEnvironment = firstCandidate.systemDependence.nodeEnvironment;
	set[Flow] firstFrontier = frontierCalculator(firstCandidate.systemDependence
										, top(graphMerger(firstCandidate.systemDependence)));
	
	Candidate secondCandidate = candidatePair.second;
	map[Vertex, node] secondEnvironment = secondCandidate.systemDependence.nodeEnvironment;
	set[Flow] secondFrontier = frontierCalculator(secondCandidate.systemDependence
										, top(graphMerger(secondCandidate.systemDependence)));
	
	rel[Flow, Flow] initialMatch = {
			*getMatch(firstFlow, secondFlow)
			| firstFlow <- firstFrontier
			, secondFlow <- secondFrontier
			, stripNode(firstEnvironment[firstFlow.target]) == stripNode(secondEnvironment[secondFlow.target])
		};
	
	rel[Flow, Flow] maximumMatch = initialMatch 
								+ calculateMaximumMatch(firstCandidate.systemDependence
										, secondCandidate.systemDependence
										, frontierCalculator, initialMatch);
	
	for(<firstFlow, secondFlow> <- maximumMatch) {
		firstCandidate.methodSpan += firstFlow.methodSpan;
		firstCandidate.highlights = addHighlights(firstCandidate.highlights, firstEnvironment, firstFlow);
			
		secondCandidate.methodSpan += secondFlow.methodSpan;
		secondCandidate.highlights = addHighlights(secondCandidate.highlights, secondEnvironment, secondFlow);
	}
	
	return <firstCandidate, secondCandidate>;
}

public CandidatePairs findMatches(CandidatePairs candidates) {
	return { matchFlows(matchFlows(pair, mergeDataGraphs, getDataFrontier), mergeControlGraphs, getControlFrontier) | pair <- candidates };
}