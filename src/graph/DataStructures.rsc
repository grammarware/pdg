module graph::DataStructures

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;


public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;

data MethodData = MethodData(str name, node abstractTree, map[int, node] nodeEnvironment, 
					set[loc] calledMethods, set[int] callSites, map[int, int] parameterNodes); 

data CallGraph = CallGraph(Graph[str] graph, map[str,loc] locations, map[str, set[str]] methodCalls);

data ControlFlow = ControlFlow(Graph[int] graph, int entryNode, set[int] exitNodes);
alias ControlFlows = map[MethodData, ControlFlow];

data PostDominator = PostDominator(Graph[int] tree, map[int, set[int]] dominators, map[int, set[int]] dominations);
alias PostDominators = map[MethodData, PostDominator];

data ControlDependence = ControlDependence(Graph[int] graph);
alias ControlDependences = map[MethodData, ControlDependence];

alias VariableData = tuple[str name, int origin];

data DataDependence = DataDependence(Graph[int] graph, map[str, set[VariableData]] defs, map[int, set[str]] uses);
alias DataDependences = map[MethodData, DataDependence];

data ProgramDependence = ProgramDependence(Graph[int] controlDependence, Graph[int] dataDependence);
alias ProgramDependences = map[MethodData, ProgramDependence];

data SystemDependence = SystemDependence(Graph[str] controlDependence, Graph[str] iControlDependence,
					  					 Graph[str] dataDependence, Graph[str] iDataDependence);

data NodeType = Normal() | Parameter() | CallSite();

anno loc node@decl;
anno loc node@src;
anno loc Expression@decl;
anno NodeType node@nodeType;

public MethodData emptyMethodData() {
	return MethodData("", ""(), (), {}, {}, ());
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