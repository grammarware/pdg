@contributor{René Bulsing - UvA MSc 2015}
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

private Graph[Vertex] mergeDataGraphs(SystemDependence systemDependence) {
	return systemDependence.dataDependence 
			+ systemDependence.globalDataDependence 
			+ systemDependence.iDataDependence;
}

private Graph[Vertex] mergeControlGraphs(SystemDependence systemDependence) {
	return systemDependence.controlDependence 
			+ systemDependence.iControlDependence;
}

private set[Vertex] firstEncountered = {};
private set[Vertex] secondEncountered = {};

private rel[Flow, Flow] calculateMatchingReach(
		SystemDependence firstSDG, 
		SystemDependence secondSDG,
		set[Flow](&A, &B) frontierCalculator, 
		Vertex firstTarget, 
		Vertex secondTarget) {
	set[Flow] firstFrontier = frontierCalculator(firstSDG, { firstTarget });
	set[Flow] secondFrontier = frontierCalculator(secondSDG, { secondTarget });
	
	rel[Flow, Flow] matchingReach = {};
	set[Vertex] firstProcessed = {};
	set[Vertex] secondProcessed = {};
	
	for(firstFlow <- firstFrontier, secondFlow <- secondFrontier) {
		if(firstFlow.target in firstEncountered && secondFlow.target in secondEncountered) {
			continue;
		}
		
		str firstSemantic = stripNode(firstSDG.nodeEnvironment[firstFlow.target]);
		str secondSemantic = stripNode(secondSDG.nodeEnvironment[secondFlow.target]);
		
		if(firstSemantic == secondSemantic) {
			matchingReach += { <firstFlow, secondFlow> };
		}
		
		firstProcessed += firstFlow.target;
		secondProcessed += secondFlow.target;
	}
	
	firstEncountered += firstProcessed;
	secondEncountered += secondProcessed;
	
	return matchingReach;
}

private rel[Flow, Flow] calculateMaximumMatch(
		SystemDependence firstSDG,
		SystemDependence secondSDG,
		set[Flow](&A, &B) frontierCalculator,
		rel[Flow, Flow] matchedFlows) {
	if(isEmpty(matchedFlows)) {
		return {};
	}
	
	rel[Flow, Flow] newMatches = {
		*calculateMatchingReach(firstSDG, secondSDG, frontierCalculator, first.target, second.target)
		| <first, second> <- matchedFlows
	};
		
	return newMatches + calculateMaximumMatch(firstSDG, secondSDG, frontierCalculator, newMatches);
}

private CandidatePair matchFlows(
			CandidatePair candidatePair, 
			Graph[Vertex](SystemDependence) graphMerger, 
			set[Flow](&A, &B) frontierCalculator) {
	firstEncountered = secondEncountered = {};
	
	Candidate firstCandidate = candidatePair.first;
	Candidate secondCandidate = candidatePair.second;
	
	map[Vertex, node] firstEnvironment = firstCandidate.systemDependence.nodeEnvironment;
	map[Vertex, node] secondEnvironment = secondCandidate.systemDependence.nodeEnvironment;
	
	rel[Flow, Flow] flowMatches = {
		*calculateMatchingReach(
			firstCandidate.systemDependence,
			secondCandidate.systemDependence,
			frontierCalculator, 
			first, 
			second
		)
		| first <- top(graphMerger(firstCandidate.systemDependence))
		, second <- top(graphMerger(secondCandidate.systemDependence))
		, stripNode(firstEnvironment[first]) == stripNode(secondEnvironment[second])
	};
	
	flowMatches	+= 	
		calculateMaximumMatch(
			firstCandidate.systemDependence,
			secondCandidate.systemDependence, 
			frontierCalculator, 
			flowMatches
		);
	
	for(<firstFlow, secondFlow> <- flowMatches) {
		firstCandidate.methodSpan += firstFlow.methodSpan;
		firstCandidate.highlights = addHighlights(firstCandidate.highlights, firstEnvironment, firstFlow);
			
		secondCandidate.methodSpan += secondFlow.methodSpan;
		secondCandidate.highlights = addHighlights(secondCandidate.highlights, secondEnvironment, secondFlow);
	}
	
	return <firstCandidate, secondCandidate>;
}

public CandidatePairs findMatches(CandidatePairs candidates) {
	return { 
		matchFlows(
			matchFlows(
				pair, 
				mergeDataGraphs, 
				getDataFrontier
			),
			mergeControlGraphs, 
			getControlFrontier
		) 
		| pair <- candidates 
	};
}