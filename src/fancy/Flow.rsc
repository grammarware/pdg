module fancy::Flow

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;
import fancy::DataStructures;

private map[Vertex, set[Vertex]] successorMap = ();

public set[Flow] flowForward(map[Vertex, node] environment, Graph[Vertex] graph, Flow flow) {
	return { Flow(flow.root
				, flow.intermediates + { flow.target }
				, successor
				, successor in environment 
					? flow.lineNumbers + environment[successor]@src.begin.line 
					: flow.lineNumbers
				, flow.methodSpan + successor.method
			) 
			| successor <- successorMap[flow.target]
			, successor notin flow.intermediates
			};
}

public bool isIntermediate(map[Vertex, node] environment, Vertex vertex) {
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

public set[Flow] expand(map[Vertex, node] environment, Graph[Vertex] graph, set[Flow] flows) {
	if(isEmpty(flows)) {
		return flows;
	}
	
	set[Flow] expandedFlows = {};
	set[Flow] unchangedFlows = {};
	
	for(flow <- flows) {
		if(flow.target in environment) {
			flow.lineNumbers += { environment[flow.target]@src.begin.line };
		}
		if(isIntermediate(environment, flow.target)) {
			expandedFlows += flowForward(environment, graph, flow);
		} else {
			unchangedFlows += { flow };
		}
	}
	
	return unchangedFlows + expand(environment, graph, expandedFlows);
}

private void calculateSuccessors(Graph[Vertex] graph, set[Vertex] environmentDomain) {
	successorMap = ();
	
	for(vertex <- carrier(graph)) {
		successorMap[vertex] = successors(graph, vertex);
	}
	
	for(vertex <- environmentDomain, vertex notin successorMap) {
		successorMap[vertex] = successors(graph, vertex);
	}
}

public set[Flow] frontier(map[Vertex, node] environment, Graph[Vertex] graph, set[Vertex] startNodes) {
	rel[Vertex, Vertex] seeds = ({} | it + { <startNode, nextNode> | nextNode <- successorMap[startNode] } | startNode <- startNodes );
	//seeds = ( seeds | it + { <startNode, startNode> } | startNode <- startNodes, startNode notin seeds );
	
	return expand(environment, graph, 
				{ Flow(root, {}, nextNode, { environment[root]@src.begin.line }, { root.method, nextNode.method } ) |
					<root, nextNode> <- seeds
					, root in environment
					, environment[root]@nodeType == Normal()
					|| environment[root]@nodeType == Global()
				});
}

public set[Flow] createDataFs(SystemDependence systemDependence) {
	Graph[Vertex] graph = systemDependence.dataDependence + systemDependence.globalDataDependence + systemDependence.iDataDependence;
	
	calculateSuccessors(graph, domain(systemDependence.nodeEnvironment));
	
	return frontier(systemDependence.nodeEnvironment, graph, domain(systemDependence.nodeEnvironment));
}

public set[Flow] createControlFs(SystemDependence systemDependence) {
	Graph[Vertex] graph = systemDependence.controlDependence + systemDependence.iControlDependence;
	
	calculateSuccessors(graph, domain(systemDependence.nodeEnvironment));
	
	return frontier(systemDependence.nodeEnvironment, graph, domain(systemDependence.nodeEnvironment));
}