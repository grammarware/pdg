@contributor{Lulu Zhang - UvA MSc 2014}
@contributor{René Bulsing - UvA MSc 2015}
module screen::SystemDependenceScreen

import Prelude;
import lang::java::m3::Core;
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
		
	SystemDependence systemDependence = createSystemDependence(methodLocation, methodAST, projectModel, File());
	
	list[Edge] edges = createEdges(systemDependence.controlDependence, "solid", "blue")
		+ createEdges(systemDependence.dataDependence, "dash", "green")
		+ createEdges(systemDependence.iControlDependence, "solid", "deepskyblue")
		+ createEdges(systemDependence.iDataDependence, "dash", "lime")
		+ createEdges(systemDependence.globalDataDependence, "dash", "lime");
	
	set[Vertex] vertices = getVertices(systemDependence);
	
	list[Figure] boxes = createSDGBoxes(systemDependence.nodeEnvironment, vertices);
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}

private set[Vertex] getVertices(SystemDependence systemDependence) {
	return carrier(systemDependence.controlDependence)
		+ carrier(systemDependence.dataDependence)
		+ carrier(systemDependence.iControlDependence)
		+ carrier(systemDependence.iDataDependence)
		+ carrier(systemDependence.globalDataDependence);
}

public str vertexIdentifier(Vertex vertex) {
	return "<vertex.file>:<vertex.method>:<vertex.identifier>";
}

public list[Edge] createEdges(Graph[Vertex] graph, str style, str color) {
	return [ edge(vertexIdentifier(graphEdge.from), vertexIdentifier(graphEdge.to), 
					lineStyle(style), lineColor(color), toArrow(box(size(10), 
					fillColor(color)))) | graphEdge <- graph ];
}

public Figures createSDGBoxes(map[Vertex, node] environment, set[Vertex] vertices) {
	return [ box(
				text("<vertex.method>:<vertex.identifier>"), 
				id(vertexIdentifier(vertex)), 
				size(50), 
				fillColor(getBoxColor(environment[vertex]@nodeType)), 
				onMouseDown(
					goToSource(
						getLocation(
							environment[vertex]
						)
					)
				)
			) | vertex <- vertices ];
}