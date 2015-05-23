module fancy::Matcher

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

import fancy::NodeStripper;
import fancy::DataStructures;
import graph::DataStructures;


public bool match(map[str, str] firstEnv, str seed1, map[str, str] secondEnv, str seed2) {
	return firstEnv[seed1] == secondEnv[seed2];
}

public set[str] nextFrontier(map[str, node] environment, Graph[str] graph, str startNode) {
	 set[str] frontier = successors(graph, startNode);
	 
	 for(frontNode <- frontier) {
	 	if(frontNode in environment && environment[frontNode] != Normal()
	 		|| frontNode notin environment) {
	 		frontier += nextFrontier(environment, graph, frontNode);
	 	}
	 }
	 
	 return { frontNode | frontNode <- frontier
	 		, frontNode in environment
	 		, environment[frontNode]@nodeType == Normal()
	 		};
}

map[Graph[str], set[loc]] matchSet1 = ();
map[Graph[str], set[loc]] matchSet2 = ();

public void prs(map[str, node] firstEnv, Graph[str] cd1, set[str] firstMatchSet,
				 map[str, node] secondEnv, Graph[str] cd2, set[str] secondMatchSet) {
	map[str, str] stripped1 = stripEnvironment(firstEnv);
	map[str, str] stripped2 = stripEnvironment(secondEnv);
	
	for(<match1, match2> <- firstMatchSet * secondMatchSet) {
		if(match(stripped1, match1, stripped2, match2)) {
			matchSet1[cd1] += { firstEnv[match1]@src };
			matchSet2[cd2] += { secondEnv[match2]@src };

			prs(firstEnv, cd1, nextFrontier(firstEnv, cd1, match1), 
				secondEnv, cd2, nextFrontier(secondEnv, cd2, match2));
		}
	}
}

public void magic(MethodSeeds methodSeeds) {
	matchSet1 = ();
	matchSet2 = ();

	for(<firstSDG, secondSDG>  <- methodSeeds) {
		Graph[str] cd1 = firstSDG.controlDependence + firstSDG.iControlDependence;
		matchSet1[cd1] = {};
		
		Graph[str] cd2 = secondSDG.controlDependence + secondSDG.iControlDependence;
		matchSet2[cd2] = {};
		
		set[str] firstMatchSet = nextFrontier(firstSDG.nodeEnvironment, cd1, getOneFrom(top(cd1)));
		set[str] secondMatchSet = nextFrontier(secondSDG.nodeEnvironment, cd2, getOneFrom(top(cd2)));
		
		prs(firstSDG.nodeEnvironment, cd1, firstMatchSet, secondSDG.nodeEnvironment, cd2, secondMatchSet);
		
		println("MATCH SET");
		for(location <- matchSet1[cd1]) {
			println(location);
		}
		
		for(location <- matchSet2[cd2]) {
			println(location);
		}
	}
}