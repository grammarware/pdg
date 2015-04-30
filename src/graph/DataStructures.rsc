module graph::DataStructures

import Prelude;
import analysis::graphs::Graph;

public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;

data ControlFlow = EmptyCF() | ControlFlow(Graph[int] graph, int entryNode, set[int] exitNodes);
data PostDominator = EmptyPD() | PostDominator(Graph[int] tree, map[int, set[int]] dominators, map[int, set[int]] dominations);
data ControlDependence = EmptyCD() | ControlDependence(Graph[int] graph);
data DataDependence =  EmptyDD() | DataDependence(Graph[int] graph, map[int, set[int]] \in, map[int, set[int]] \out);
data MethodData = MethodData(str name, node abstractTree, map[int, node] nodeEnvironment, set[loc] calledMethods, ControlFlow controlFlow, 
								PostDominator postDominator, ControlDependence controlDependence, DataDependence dataDependence); 

public MethodData emptyMethodData() {
	return MethodData("", ""(), (), {}, EmptyCF(), EmptyPD(), EmptyCD(), EmptyDD());
}

public set[int] environmentDomain(MethodData methodData) {
	return domain(methodData.nodeEnvironment);
}

public node resolveIdentifier(MethodData methodData, int identifier) {
	return methodData.nodeEnvironment[identifier];
}

public str nodeName(MethodData methodData, int identifier) {
	if(/^<name:\w*>/ := "<methodData.nodeEnvironment[identifier]>") {
		return name;
	}
	
	return "";
}