module screen::SystemDependenceScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::AST;

import screen::Screen;
import extractors::Project;

import creator::CFGCreator;
import graph::DataStructures;
import graph::\data::DDG;
import graph::system::SDG;
import graph::control::PDT;
import graph::control::dependence::CDG;

@doc {
	To run a test:
		displaySystemDependenceGraph(|project://JavaTest|, "main");
}
public void displaySystemDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
		
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel);
	PostDominators postDominators = ( method : createPDT(method, controlFlows[method]) | method <- controlFlows );
	ControlDependences controlDependences = ( 
		  method : createCDG(method, controlFlows[method], postDominators[method]) 
		| method <- postDominators 
	);
	DataDependences dataDependences = ( method : createDDG(method, controlFlows[method]) | method <- controlFlows );
	SystemDependence systemDependence = createSDG(controlDependences, dataDependences);
	
	list[Edge] edges = createEdges(systemDependence.controlDependence, "solid", "blue")
		+ createEdges(systemDependence.dataDependence, "dash", "green")
		+ createEdges(systemDependence.iControlDependence, "solid", "deepskyblue")
		+ createEdges(systemDependence.iDataDependence, "dash", "lime");
	
	list[Figure] boxes = ([] | it + createSDGBoxes(method) | method <- controlDependences);
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

public list[Edge] createEdges(Graph[str] graph, str style, str color) {
	return [ edge(graphEdge.from, graphEdge.to, 
					lineStyle(style), lineColor(color), toArrow(box(size(10), 
					fillColor(color)))) | graphEdge <- graph ];
}

private str getBoxColor(NodeType nodeType) {
	switch(nodeType) {
		case Normal(): return "lightgreen";
		case CallSite(): return "lightpink";
		case Parameter(): return "beige";
	}
}

public Figures createSDGBoxes(MethodData methodData) {
	return [ box(
				text("<methodData.name>:<treeNode>"), 
				id(encodeVertex(methodData, treeNode)), 
				size(50), 
				fillColor(getBoxColor(resolveIdentifier(methodData, treeNode)@nodeType)), 
				onMouseDown(
					goToSource(
						getLocation(
							resolveIdentifier(methodData, treeNode)
						)
					)
				)
			) | treeNode <- environmentDomain(methodData) ]
			+ box(text("ENTRY <methodData.name>"), id(encodeVertex(methodData, ENTRYNODE)), size(50), fillColor("lightblue"));
}