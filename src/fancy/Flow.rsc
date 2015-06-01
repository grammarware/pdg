module fancy::Flow

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;
import fancy::DataStructures;

private map[str, set[str]] successorMap = ();

public set[Flow] flowForward(Graph[str] graph, Flow flow) {
	return { Flow(flow.root, flow.intermediates + { flow.target }, successor) | successor <- successorMap[flow.target], successor notin flow.intermediates };
}

public bool isIntermediate(map[str, node] environment, str vertex) {
	if(vertex notin environment 
		|| (environment[vertex]@nodeType != Normal() && environment[vertex]@nodeType != Global())) {
		return true;
	}
	
	switch(environment[vertex]) {
		case m: \methodCall(_, _, _): {
			try return m@src.file == "<m@decl.parent.file>.java";
			catch: return false;
		}
    	case m: \methodCall(_, _, _, _): {
    		try return m@src.file == "<m@decl.parent.file>.java";
			catch: return false;
    	}
    	case \do(_, _):
    		return true;
    	case \foreach(_, _, _):
    		return true;
    	case \for(_, _, _, _):
    		return true;
    	case \for(_, _, _):
    		return true;
    	case \if(_, _):
    		return true;
    	case \if(_, _, _):
    		return true;
		case \switch(_, _):
			return true;
		case \while(_, _):
			return true;
	}
	
	return false;
}

public set[Flow] expand(map[str, node] environment, Graph[str] graph, set[Flow] flows) {
	if(isEmpty(flows)) {
		return flows;
	}
	
	set[Flow] expandedFlows = {};
	set[Flow] unchangedFlows = {};
	
	for(flow <- flows) {
		if(isIntermediate(environment, flow.target)) {
			expandedFlows += flowForward(graph, flow);
		} else {
			unchangedFlows += { flow };
		}
	}
	
	return unchangedFlows + expand(environment, graph, expandedFlows);
}

private void calculateSuccessors(Graph[str] graph, set[str] environmentDomain) {
	successorMap = ();
	
	for(vertex <- carrier(graph)) {
		successorMap[vertex] = successors(graph, vertex);
	}
	
	for(vertex <- environmentDomain, vertex notin successorMap) {
		successorMap[vertex] = successors(graph, vertex);
	}
}

public set[Flow] frontier(map[str, node] environment, Graph[str] graph, set[str] startNodes) {
	rel[str, str] seeds = ({} | it + { <startNode, nextNode> | nextNode <- successorMap[startNode] } | startNode <- startNodes );
	//seeds = ( seeds | it + { <startNode, startNode> } | startNode <- startNodes, startNode notin seeds );
	
	return expand(environment, graph, 
				{ Flow(root, {}, nextNode) |
					<root, nextNode> <- seeds
					, root in environment
					, environment[root]@nodeType == Normal()
					|| environment[root]@nodeType == Global()
				});
}

public set[Flow] createDataFs(SystemDependence systemDependence) {
	Graph[str] graph = systemDependence.dataDependence + systemDependence.globalDataDependence + systemDependence.iDataDependence;
	
	calculateSuccessors(graph, domain(systemDependence.nodeEnvironment));
	
	return frontier(systemDependence.nodeEnvironment, graph, domain(systemDependence.nodeEnvironment));
}

public set[Flow] createControlFs(SystemDependence systemDependence) {
	Graph[str] graph = systemDependence.controlDependence + systemDependence.iControlDependence;
	
	calculateSuccessors(graph, domain(systemDependence.nodeEnvironment));
	
	return frontier(systemDependence.nodeEnvironment, graph, domain(systemDependence.nodeEnvironment));
}