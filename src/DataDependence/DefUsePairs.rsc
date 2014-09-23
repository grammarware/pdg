module DataDependence::DefUsePairs

import lang::java::m3::AST;
import ADT;
import ControlDependence::ControlFlow;
import Utils::Map;
import Utils::ListRelation;
import IO;

public map[int use, rel[int def, str name] defs] computeDefUsePairs(map[int, map[str, set[int]]] inputs, map[int, set[str]] uses){
	map[int, rel[int, str]] duPairs= ();
	for(u <- uses){
		reachingDefs = inputs[u];
		for(variable <- uses[u], variable in reachingDefs){
			if(u notin duPairs) duPairs[u] = {<def, variable> | def <- reachingDefs[variable]};
			else duPairs[u] += {<def, variable> | def <- reachingDefs[variable]};
		}
	}
	return duPairs;
}