module screen::SystemDependenceScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import analysis::m3::Registry;
import lang::java::m3::AST;

import screen::Screen;
import extractors::Project;
import graph::system::SDG;
import graph::DataStructures;
import graph::factory::GraphFactory;


@doc{
	To run a test:
		displaySystemDependenceGraph(|project://JavaTest|, "main");
}
public void displaySystemDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	
	displaySystemDependenceGraph(projectModel, methodLocation);
}

public void displaySystemDependenceGraph(loc project, str methodName, str fileName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, fileName, projectModel);
	
	displaySystemDependenceGraph(projectModel, methodLocation);
}

private void displaySystemDependenceGraph(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
		
	ControlDependences controlDependences = createControlDependences(methodLocation, methodAST, projectModel, File());
	DataDependences dataDependences = createDataDependences(methodLocation, methodAST, projectModel, File());
	SystemDependence systemDependence = createSDG(controlDependences, dataDependences);
	
	list[Edge] edges = createEdges(systemDependence.controlDependence, "solid", "blue")
		+ createEdges(systemDependence.dataDependence, "dash", "green")
		+ createEdges(systemDependence.iControlDependence, "solid", "deepskyblue")
		+ createEdges(systemDependence.iDataDependence, "dash", "lime")
		+ createEdges(systemDependence.globalDataDependence, "dash", "lime");
	
	list[Figure] boxes = ([] | it + createSDGBoxes(method) | method <- controlDependences);
	boxes += createGlobalBoxes(systemDependence.nodeEnvironment, systemDependence.globalDataDependence);
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

public str vertexName(Vertex vertex) {
	return "<vertex.file>:<vertex.method>:<vertex.identifier>";
}

public list[Edge] createEdges(Graph[Vertex] graph, str style, str color) {
	return [ edge(vertexName(graphEdge.from), vertexName(graphEdge.to), 
					lineStyle(style), lineColor(color), toArrow(box(size(10), 
					fillColor(color)))) | graphEdge <- graph ];
}

private str getBoxColor(NodeType nodeType) {
	switch(nodeType) {
		case Normal(): return "lightgreen";
		case CallSite(): return "lightpink";
		case Parameter(): return "beige";
		case Global(): return "darkorange";
	}
}

public Figures createGlobalBoxes(map[Vertex, node] environment, Graph[Vertex] graph) {
	return [ box(
				text("<vertex.file>:<vertex.method>"), 
				id(vertexName(vertex)), 
				size(50), 
				fillColor(getBoxColor(environment[vertex]@nodeType)), 
				onMouseDown(
					goToSource(
						getLocation(
							environment[vertex]
						)
					)
				)
			) | vertex <- domain(graph) ];
}

public str strip(str name) {
	if(/^<name:.*>\(/ := name) {
		return name;
	}
	
	return "";
}

public Figures createSDGBoxes(MethodData methodData) {
	return [ box(
				text("<strip(methodData.name)>:<treeNode>"), 
				id(vertexName(encodeVertex(methodData, treeNode))), 
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
			+ box(text("ENTRY <strip(methodData.name)>"), id(vertexName(encodeVertex(methodData, ENTRYNODE))), size(50), fillColor("lightblue"));
}