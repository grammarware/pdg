module fancy::Flow

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;

data Flow = Flow(str root, set[str] intermediates, str target);

public set[Flow] flowForward(Graph[str] graph, Flow flow) {
	return { Flow(flow.root, flow.intermediates + { flow.target } - { flow.root }, successor) | successor <- successors(graph, flow.target) };
}

public bool isIntermediate(map[str, node] environment, str vertex) {
	if(environment[vertex]@nodeType != Normal()) {
		return true;
	}
	
	switch(environment[vertex]) {
		case m: \methodCall(_, _, _):
			return m@src.parent.file == resolveM3(m@decl).parent.file;
    	case m: \methodCall(_, _, _, _):
    		return m@src.parent.file == m@decl.parent.file;
    	case \do(_, _):
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
	}
	
	return false;
}

public set[Flow] expand(map[str, node] environment, Graph[str] graph, set[Flow] flows) {
	set[Flow] expanded = {};
	bool changed = false;
	set[Flow] addedFlow = {};
	
	for(flow <- flows) {
		addedFlow = { flow };

		if(flow.target notin environment || isIntermediate(environment, flow.target)) {
			addedFlow = flowForward(graph, flow);
			changed = true;
		}
		
		expanded += addedFlow;
	}
	
	
	return changed ? expand(environment, graph, expanded) : expanded;
}

public set[Flow] frontier(map[str, node] environment, Graph[str] graph, set[str] startNodes) {
	return expand(environment, graph, 
				{ Flow(root, {}, nextNode) |
					root <- startNodes
					, root in environment
					, environment[root]@nodeType == Normal() 
					, nextNode <- successors(graph, root)
				});
}