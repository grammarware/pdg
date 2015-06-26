module clone::flow::Creator

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

import graph::DataStructures;
import clone::DataStructures;

private map[Vertex, set[Vertex]] successorMap = ();

public set[Flow] flowForward(map[Vertex, node] environment, Graph[Vertex] graph, Flow flow) {
	return { Flow(flow.root
				, flow.intermediates + { flow.target }
				, successor
				, successor in environment 
					? flow.lineNumbers + environment[successor]@src.begin.line 
					: flow.lineNumbers
				, flow.methodSpan + "<successor.file>:<successor.method>"
			) 
			| successor <- successorMap[flow.target]
			, successor notin flow.intermediates
			};
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

private set[Flow] frontier(map[Vertex, node] environment, Graph[Vertex] graph, set[Vertex] startNodes) {
	rel[Vertex, Vertex] seeds = ({} 
			| it + { <startNode, nextNode> 
			| nextNode <- successorMap[startNode] } | startNode <- startNodes 
		);
	
	return expand(environment, graph, 
				{ Flow(root, {}, nextNode, { environment[root]@src.begin.line } 
						, { "<root.file>:<root.method>", "<nextNode.file>:<nextNode.method>" } ) 
					| <root, nextNode> <- seeds
					, root in environment
					, environment[root]@nodeType == Normal() || environment[root]@nodeType == Global()
				}
			);
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