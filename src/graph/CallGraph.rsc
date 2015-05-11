module graph::CallGraph

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;

import extractors::Project;

anno loc Expression@decl;

public list[Edge] createEdges(Graph[str] callGraph) {
	return [ edge(graphEdge.from, graphEdge.to, 
					lineStyle("dash"), lineColor("black"), toArrow(box(size(10), 
					fillColor("black")))) | graphEdge <- callGraph ];
}

public Figures createBoxes(Graph[str] callGraph) {	
	return [ box(text(vertex), id(vertex), size(50), fillColor("lightgreen")) | vertex <- carrier(callGraph) ];
}

public str getVertexName(loc location) {
	loc resolvedLocation = resolveM3(location);
	
	return "<resolvedLocation.file>:<location.file>:<resolvedLocation.begin.line>";
}

public void testMethodCount() {
	M3 projectModel = createM3(|project://QL|);
	set[loc] projectMethods = getM3Methods(projectModel);
	println("Method count: <size(projectMethods)>");
	
	loc methodLocation = getOneFrom(projectMethods);
	loc resolvedLocation = resolveM3(methodLocation);
	
	Graph[str] callGraph = {};
	
	for(method <- projectMethods) {
		node methodAST = getMethodASTEclipse(method, model = projectModel);
		
		visit(methodAST) {
			case methodCall: \methodCall(isSuper, name, arguments): {
				if(methodCall@decl in projectMethods) {
					callGraph += { <getVertexName(method), getVertexName(methodCall@decl)> };
				}
			}
	    	case methodCall: \methodCall(isSuper, receiver, name, arguments): {
	    		if(methodCall@decl in projectMethods) {
					callGraph += { <getVertexName(method), getVertexName(methodCall@decl)> };
				}
	    	}
		}		
	}
	
	render(graph(createBoxes(callGraph), createEdges(callGraph), hint("layered"), gap(50)));
}