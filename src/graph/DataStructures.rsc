module graph::DataStructures

import Prelude;
import analysis::graphs::Graph;

public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;

data FlowGraph = FlowGraph(Graph[int] edges, int entryNode, set[int] exitNodes, set[loc] calledMethods, map[int, node] nodeEnvironment);

public set[int] environmentDomain(FlowGraph flowGraph) {
	return domain(flowGraph.nodeEnvironment);
}

public node resolveIdentifier(FlowGraph flowGraph, int identifier) {
	return flowGraph.nodeEnvironment[identifier];
}

public str nodeName(FlowGraph flowGraph, int identifier) {
	if(/^<name:\w*>/ := "<flowGraph.nodeEnvironment[identifier]>") {
		return name;
	}
	
	return "";
}