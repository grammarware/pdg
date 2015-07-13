module graph::DataStructures

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import analysis::graphs::Graph;


public int GLOBALNODE = -4;
public int ENTRYNODE = -3;
public int STARTNODE = -2;
public int EXITNODE = -1;

data MethodData = MethodData(str name, node abstractTree, map[int, node] nodeEnvironment, 
					set[loc] calledMethods, set[int] callSites, map[int, int] parameterNodes); 

alias MethodName = str;
alias FileName = str;
data CallVertex = CallVertex(loc location, str file, str method, str identifier);
data CallGraph = CallGraph(Graph[CallVertex] graph
							, map[MethodName, set[CallVertex]] locations
							, map[CallVertex, set[CallVertex]] methodCalls
							, map[MethodName, FileName] methodFileMapping
							, map[FileName, set[MethodName]] fileMethodsMapping);

data ControlFlow = EmptyCF()
					| ControlFlow(Graph[int] graph, int entryNode, set[int] exitNodes);
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

data SystemDependence = EmptySD(M3 model, loc location)
						| SystemDependence(map[Vertex, node] nodeEnvironment,
										Graph[Vertex] controlDependence, Graph[Vertex] iControlDependence,
					  					Graph[Vertex] dataDependence, Graph[Vertex] globalDataDependence, Graph[Vertex] iDataDependence);

data Vertex = Vertex(str file, str method, int identifier);

data NodeType = Normal() | Parameter() | CallSite() | Entry() | Global();

anno loc node@decl;
anno loc node@src;
anno loc Expression@decl;
anno NodeType node@nodeType;

public bool isParameterVariable(str variable) =
	/^\$/ := variable;

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