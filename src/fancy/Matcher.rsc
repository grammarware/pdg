module fancy::Matcher

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

import fancy::Flow;
import fancy::NodeStripper;
import fancy::DataStructures;
import graph::DataStructures;


alias Translations = rel[tuple[str, str], Flow];

public Translations translateFlows(map[str, node] environment, set[Flow] flows) {
	map[str, str] strippedEnvironment = stripEnvironment(environment);
	
	return { < <strippedEnvironment[flow.root], strippedEnvironment[flow.target]>, flow > | flow <- flows };
}

public void printSources(map[str, node] firstEnv, Flow first, map[str, node] secondEnv, Flow second) {
	loc firstFile = toLocation(firstEnv[first.root]@src.uri);
	loc secondFile = toLocation(secondEnv[second.root]@src.uri);
	
	if(firstFile notin lineMatches) {
		lineMatches[firstFile] = {};
		lineMatches[secondFile] = {};
	}

	lineMatches[firstFile] += { firstEnv[first.root]@src.begin.line };
	lineMatches[firstFile] += { firstEnv[inter]@src.begin.line | inter <- first.intermediates, inter in firstEnv };
	lineMatches[firstFile] += { firstEnv[first.target]@src.begin.line };
	
	lineMatches[secondFile] += { secondEnv[second.root]@src.begin.line };
	lineMatches[secondFile] += { secondEnv[inter]@src.begin.line | inter <- second.intermediates, inter in secondEnv };
	lineMatches[secondFile] += { secondEnv[second.target]@src.begin.line };
}

map[loc, set[int]] lineMatches = ();

public void flowMatcher(map[str, node] firstEnv, set[Flow] first, map[str, node] secondEnv, set[Flow] second) {
	Translations firstTranslations = translateFlows(firstEnv, first);
	Translations secondTranslations = translateFlows(secondEnv, second);
	
	for(<key, val> <- firstTranslations) {
		println("[First] <key>, Root: <firstEnv[val.root]@src>, Target: <firstEnv[val.target]@src>");
	}
	
	for(<key, val> <- secondTranslations) {
		println("[Second] <key>, Root: <secondEnv[val.root]@src>, Target: <secondEnv[val.target]@src>");
	}
	
	for(key <- domain(firstTranslations)) {
		if(key in domain(secondTranslations)) {
			for(f <- firstTranslations[key], s <- secondTranslations[key])
				printSources(firstEnv, f, secondEnv, s);
		}
	}
}	

public map[loc, set[int]] magic(MethodSeeds methodSeeds) {
	lineMatches = ();

	for(<firstSDG, secondSDG>  <- methodSeeds) {
		Graph[str] cd1 = firstSDG.controlDependence + firstSDG.iControlDependence;
		Graph[str] dd1 = firstSDG.dataDependence + firstSDG.iDataDependence;
		
		Graph[str] cd2 = secondSDG.controlDependence + secondSDG.iControlDependence;
		Graph[str] dd2 = secondSDG.dataDependence + secondSDG.iDataDependence;
		
		set[Flow] controls1 = createFlows(firstSDG.nodeEnvironment, cd1);
		set[Flow] controls2 = createFlows(secondSDG.nodeEnvironment, cd2);	
		
		flowMatcher(firstSDG.nodeEnvironment, controls1, secondSDG.nodeEnvironment, controls2);
		
		set[Flow] datas1 = createFlows(firstSDG.nodeEnvironment, dd1);
		set[Flow] datas2 = createFlows(secondSDG.nodeEnvironment, dd2);
		
		flowMatcher(firstSDG.nodeEnvironment, datas1, secondSDG.nodeEnvironment, datas2);
	}
	
	println(lineMatches);
	return lineMatches;
}