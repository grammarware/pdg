module fancy::Matcher

import Prelude;
import analysis::graphs::Graph;

import fancy::NodeStripper;
import fancy::DataStructures;
import graph::DataStructures;


private alias Translations = rel[tuple[str root, str target], Flow];

public Translations translateFlows(map[Vertex, node] environment, set[Flow] flows) {
	return { < <stripNode(environment[flow.root]), stripNode(environment[flow.target])>, flow > | flow <- flows };
}

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

private CandidatePair matchControlFlows(CandidatePair candidatePair) {
	Candidate firstCandidate = candidatePair.first;
	map[Vertex, node] firstEnvironment = firstCandidate.systemDependence.nodeEnvironment;
	Translations firstTranslations = translateFlows(firstEnvironment, firstCandidate.flows.control);
	
	Candidate secondCandidate = candidatePair.second;
	map[Vertex, node] secondEnvironment = secondCandidate.systemDependence.nodeEnvironment;
	Translations secondTranslations = translateFlows(secondEnvironment, secondCandidate.flows.control);
	
	for(key <- domain(firstTranslations), key in domain(secondTranslations)) {
		for(firstFlow <- firstTranslations[key], secondFlow <- secondTranslations[key]) {
			firstCandidate.methodSpan += firstFlow.methodSpan;
			firstCandidate.highlights = addHighlights(firstCandidate.highlights, firstEnvironment, firstFlow);
			
			secondCandidate.methodSpan += secondFlow.methodSpan;
			secondCandidate.highlights = addHighlights(secondCandidate.highlights, secondEnvironment, secondFlow);
		}
	}
	
	return <firstCandidate, secondCandidate>;
}

private CandidatePair matchDataFlows(CandidatePair candidatePair) {
	Candidate firstCandidate = candidatePair.first;
	map[Vertex , node] firstEnvironment = firstCandidate.systemDependence.nodeEnvironment;
	Translations firstTranslations = translateFlows(firstEnvironment, firstCandidate.flows.\data);
	
	Candidate secondCandidate = candidatePair.second;
	map[Vertex , node] secondEnvironment = secondCandidate.systemDependence.nodeEnvironment;
	Translations secondTranslations = translateFlows(secondEnvironment, secondCandidate.flows.\data);
	
	for(key <- domain(firstTranslations), key in domain(secondTranslations)) {
		for(firstFlow <- firstTranslations[key], secondFlow <- secondTranslations[key]) {
			firstCandidate.methodSpan += firstFlow.methodSpan;
			firstCandidate.highlights = addHighlights(firstCandidate.highlights, firstEnvironment, firstFlow);
			
			secondCandidate.methodSpan += secondFlow.methodSpan;
			secondCandidate.highlights = addHighlights(secondCandidate.highlights, secondEnvironment, secondFlow);
		}
	}
	
	return <firstCandidate, secondCandidate>;
}

private CandidatePair matchFlows(CandidatePair candidatePair) {
	return matchControlFlows(matchDataFlows(candidatePair));
}

private int lineSpan(Candidate candidate) {
	int span = 0;
	
	for(lineNumbers <- range(candidate.highlights)) {
		span += size(lineNumbers);
	}
	
	return span;
}

private bool isFiltered(CandidatePair pair) {	
	if((lineSpan(pair.first) < 4 && lineSpan(pair.second) < 4)
		|| (size(pair.first.methodSpan) == 1 && size(pair.second.methodSpan) == 1)
		|| (size(pair.first.methodSpan) == size(pair.second.methodSpan))) {
		return true;
	}
	
	return false;
}

public CandidatePairs findMatches(CandidatePairs candidates) {
	return { pair 
			| pair <- { matchFlows(pair) | pair <- candidates }
			, !isFiltered(pair)
			};
}