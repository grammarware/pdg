module DataDependence

import IO;
import Types;
import lang::java::m3::AST;
import Utils::Map;
import Utils::ListRelation;
import graph::control::Flow;

public tuple[map[int, map[int, set[str]]] inputs, map[int, map[int, set[str]]] outputs] getReachingDefs(ControlFlow cf, map[int number, Statement stat] statements, map[str, set[int]] defs, map[int, set[str]] gens){
	map[int, map[int, set[str]]] kills = ();
	map[int, map[int, set[str]]] outputs = ();
	map[int, map[int, set[str]]] inputs = ();
	
	map[int, list[int]] preds = getPredecessors(cf.edges);
	for(s <- statements){
		if(s in gens){
			kills[s] = ();
			for(var <- gens[s]){
				for(stat <- defs[var])
					kills[s] = insertInToMap(var, stat, kills[s]);
			} 
		}else{
			gens[s] = {};
			kills[s] = ();
		}
		//initialize outputs and inputs
		outputs[s]= (s: gens[s]);
		inputs[s] = ();
	}
	
	bool change = true;
	while(change){
		change = false;
		for(s <- statements){
			if(s in preds) inputs[s] = mergeMaps([outputs[p] | p <- preds[s]]);
			oldOut = outputs[s];
			outputs[s] = inputs[s] - kills[s] + (s: gens[s]);
			if(outputs[s] != oldOut) change = true;
		}
	}
	
	return <inputs, outputs>;
}

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

public map[int use, rel[int def, str name] defs] buildDataDependence(ControlFlow cf, map[int number, Statement stat] statements, map[str, set[int]] defs, map[int, set[str]] gens, map[int, set[str]] uses){
	io = getReachingDefs(cf, statements, defs, gens);
	duPairs = computeDefUsePairs(reverseKeyValue(io.inputs), uses);
	return duPairs;
}

