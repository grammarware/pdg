module fancy::Matcher

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

import fancy::DataStructures;
import graph::DataStructures;


private str getNodeName(node treeNode) {
	if(/^<name:\w*>/ := "<treeNode>") {
		return name;
	}
	
	return "<treeNode>";
}

public bool match(map[str, node] firstEnv, str seed1, map[str, node] secondEnv, str seed2) {	
	node firstStatement = firstEnv[seed1];
	node secondStatement = secondEnv[seed2];
	
	if(getNodeName(firstStatement) == getNodeName(secondStatement)) {
		println("=== MATCH === \n\t <firstStatement@src> \n\t <secondStatement@src>");
		return true;
	}
	
	return false;
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

public void prs(map[str, node] firstEnv, Graph[str] cd1, set[str] firstMatchSet,
				 map[str, node] secondEnv, Graph[str] cd2, set[str] secondMatchSet) {	
	for(<match1, match2> <- firstMatchSet * secondMatchSet) {
		if(match(firstEnv, match1, secondEnv, match2)) {
			prs(firstEnv, cd1, nextFrontier(firstEnv, cd1, match1), secondEnv, cd2, nextFrontier(secondEnv, cd2, match2));
		}
	}
}

public void magic(MethodSeeds methodSeeds) {
	for(<firstSDG, secondSDG>  <- methodSeeds) {
		Graph[str] cd1 = firstSDG.controlDependence + firstSDG.iControlDependence;
		Graph[str] cd2 = secondSDG.controlDependence + secondSDG.iControlDependence;
		
		set[str] firstMatchSet = nextFrontier(firstSDG.nodeEnvironment, cd1, getOneFrom(top(cd1)));
		set[str] secondMatchSet = nextFrontier(secondSDG.nodeEnvironment, cd2, getOneFrom(top(cd2)));
		
		prs(firstSDG.nodeEnvironment, cd1, firstMatchSet, secondSDG.nodeEnvironment, cd2, secondMatchSet);
	}
}