module graph::control::DataStructures

import analysis::graphs::Graph;

data FlowGraph = FlowGraph(Graph[int] edges, int entryNode, set[int] exitNodes);

public int STARTNODE = -2;
public int EXITNODE = -1;