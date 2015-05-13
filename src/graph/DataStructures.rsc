module graph::DataStructures

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;

public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;

data CallGraph = EmptyCG()
				| CallGraph(Graph[str] graph, map[str,loc] locations, map[str, set[str]] methodCalls);
data ControlFlow = EmptyCF() 
				 | ControlFlow(Graph[int] graph, int entryNode, set[int] exitNodes);
data PostDominator = EmptyPD() 
				   | PostDominator(Graph[int] tree, map[int, set[int]] dominators, map[int, set[int]] dominations);
data ControlDependence = EmptyCD() 
					   | ControlDependence(Graph[int] graph);
data DataDependence = EmptyDD() 
					| DataDependence(Graph[int] graph, map[int, set[int]] \in, map[int, set[int]] \out, map[str, set[int]] defs, map[int, set[str]] uses);
data MethodData = MethodData(str name, node abstractTree, map[int, node] nodeEnvironment, set[loc] calledMethods, map[int, int] parameterNodes); 

data NodeType = Normal() | Parameter() | CallSite();

anno loc node@src;
anno loc Expression@decl;
anno NodeType node@nodeType;

public MethodData emptyMethodData() {
	return MethodData("", ""(), (), {}, ());
}

public set[int] environmentDomain(MethodData methodData) {
	return domain(methodData.nodeEnvironment);
}

public node resolveIdentifier(MethodData methodData, int identifier) {
	return methodData.nodeEnvironment[identifier];
}

public str nodeName(MethodData methodData, int identifier) =
	/^<name:\w*>/ := "<methodData.nodeEnvironment[identifier]>"
	? name
	: "";

public &T cast(type[&T] tp, value v) throws str {
    if (&T tv := v) {
        return tv;
    } else {
        throw "cast failed";
    }
}