module screen::PostDominatorScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::AST;

import extractors::Project;

import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;

@doc {
	To run a test:
		displayPostDominatorTree(|project://pdg-JavaTest|, "testPDT");
		displayPostDominatorTree(|project://pdg-JavaTest|, "testPDT2");
		displayPostDominatorTree(|project://pdg-JavaTest|, "testCDG");
}
public void displayPostDominatorTree(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	FlowGraph flowGraph = createCFG(methodAST);
	Graph[int] postDominator = createPDT(flowGraph);
	
	render(graph(createBoxes(postDominator), createEdges(postDominator), hint("layered"), gap(50)));
}

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	return |file://methodDoesNotExist|;
}

private list[Edge] createEdges(Graph[int] tree) {
	list[Edge] edges = [];

	for(graphEdge <- tree) {
		edges += edge("<graphEdge.from>", "<graphEdge.to>", toArrow(box(size(10), fillColor("black"))));
	}
	
	return edges;
}

private Figures createBoxes(Graph[int] tree) {
	Figures boxes = [];
	
	for(treeNode <- getNodeIdentifiers()) {
		loc location = getLocation(resolveIdentifier(treeNode));
		boxes += box(text("<treeNode>"), id("<treeNode>"), size(50), fillColor("lightgreen"),
					onMouseDown(goToSource(location)));
	}
	
	boxes += box(text("EXIT"), id("<EXITNODE>"), size(50), fillColor("lightblue"));
	boxes += box(text("START"), id("<STARTNODE>"), size(50), fillColor("lightblue"));
	boxes += box(text("ENTRY"), id("<ENTRYNODE>"), size(50), fillColor("lightblue"));
	
	return boxes;
}

public &T cast(type[&T] tp, value v) throws str {
    if (&T tv := v) {
        return tv;
    } else {
        throw "cast failed";
    }
}

public loc getLocation(node stat){
	return cast(#loc, getAnnotations(stat)["src"]);
}

public bool(int button, map[KeyModifier,bool] modifiers) goToSource(loc location) =
	bool(int button, map[KeyModifier,bool] modifiers)
	{ 
	    if(button == 1) {
	        edit(location,[]);
	        return true;
	    }
	    return false;
	};