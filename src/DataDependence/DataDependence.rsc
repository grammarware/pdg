module DataDependence::DataDependence

import lang::java::m3::AST;
import IO;
import ADT;
import ControlDependence::ControlFlow;
import Utils::Map;
import Utils::ListRelation;
import DataDependence::ReachingDefs;
import DataDependence::DefUsePairs;

//map[str var, list[int] stats] defs = ();
//map[int stat, list[str] vars] gens = ();

public map[int use, rel[int def, str name] defs] buildDataDependence(CF cf, map[int number, Statement stat] statements, map[str, set[int]] defs, map[int, set[str]] gens, map[int, set[str]] uses){
	io = getReachingDefs(cf, statements, defs, gens);
	duPairs = computeDefUsePairs(statements, reverseKeyValue(io.inputs), uses);
	return duPairs;
}

