@contributor{René Bulsing - UvA MSc 2015}
module clone::flow::Creator

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

import graph::DataStructures;
import clone::DataStructures;


private set[str] spanIdentifier(Vertex graphNode) {
	if(graphNode.method == "Global") {
		return {};
	}
	
	return { "<graphNode.file>:<graphNode.method>" };
}

private set[Flow] flowForward(map[Vertex, node] environment, Graph[Vertex] graph, Flow flow) {
	return { Flow(flow.root
					, flow.intermediates + { flow.target }
					, successor
					, successor in environment 
						? flow.lineNumbers + getSrc(environment[successor]).begin.line 
						: flow.lineNumbers
					, flow.methodSpan + spanIdentifier(successor)
				) 
			| successor <- successors(graph, flow.target)
			, successor notin flow.intermediates
			};
}

private set[Flow] getFrontier(map[Vertex, node] environment, Graph[Vertex] graph, set[Flow] flows) {
	if(isEmpty(flows)) {
		return flows;
	}
	
	set[Flow] expandedFlows = {};
	set[Flow] unchangedFlows = {};
	
	for(flow <- flows) {
		if(flow.target in environment) {
			flow.lineNumbers += { getSrc(environment[flow.target]).begin.line };
		}
		
		if(isIntermediate(environment, flow.target)) {
			expandedFlows += flowForward(environment, graph, flow);
		} else {
			unchangedFlows += { flow };
		}
	}
	
	return unchangedFlows + getFrontier(environment, graph, expandedFlows);
}

private Flow initializeFlow(map[Vertex, node] environment, Vertex root, Vertex nextNode) {
	return 	Flow(root
				, {}
				, nextNode
				, { getSrc(environment[root]).begin.line } 
				, spanIdentifier(root) + spanIdentifier(nextNode) 
			);
}

public set[Flow] getDataFrontier(SystemDependence systemDependence, set[Vertex] startNodes) {
	Graph[Vertex] graph = systemDependence.dataDependence 
						+ systemDependence.globalDataDependence 
						+ systemDependence.iDataDependence;
	
	set[Flow] flows = 
		{ initializeFlow(systemDependence.nodeEnvironment, startNode, nextNode) 
			| startNode <- startNodes 
			, nextNode <- successors(graph, startNode) 
		};
	
	return getFrontier(systemDependence.nodeEnvironment, graph, flows);
}

public set[Flow] getControlFrontier(SystemDependence systemDependence, set[Vertex] startNodes) {
	Graph[Vertex] graph = systemDependence.controlDependence 
						+ systemDependence.iControlDependence;
	
	set[Flow] flows = 
		{ initializeFlow(systemDependence.nodeEnvironment, startNode, nextNode) 
			| startNode <- startNodes 
			, nextNode <- successors(graph, startNode) 
		};
	
	return getFrontier(systemDependence.nodeEnvironment, graph, flows);
}