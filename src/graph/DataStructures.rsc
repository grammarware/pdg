module graph::DataStructures

import analysis::graphs::Graph;

data FlowGraph = FlowGraph(Graph[int] edges, int entryNode, set[int] exitNodes);

public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;
