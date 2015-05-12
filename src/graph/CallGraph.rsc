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
	
	return "<resolvedLocation.file>:<location.file>";
}

anno loc node@src;

public void testMethodCount() {
	M3 projectModel1 = createM3(|project://junit-r4.9|);
	registerProject(|project://junit-r4.9|, projectModel1);
	
	set[loc] projectMethods1 = getM3Methods(projectModel1);
	
	println("Method count for JUnit 4.9: <size(projectMethods1)>");
	
	Graph[str] callGraph = {};

	map[str, set[str]] methodCalls1 = ();
	map[str, loc] locations1 = ();
	
	for(method <- projectMethods1) {
		try node methodAST = getMethodASTEclipse(method, model = projectModel1);
		catch: continue;
		
		str methodVertex = getVertexName(method);
		
		locations1[methodVertex] = methodAST@src;
		methodCalls1[methodVertex] = {};
		
		visit(methodAST) {
			case methodCall: \methodCall(isSuper, name, arguments): {
				if(methodCall@decl in projectMethods1) {
					str calledVertex = getVertexName(methodCall@decl);
					callGraph += { <methodVertex, calledVertex> };
					methodCalls1[methodVertex] += { calledVertex };
				}
			}
	    	case methodCall: \methodCall(isSuper, receiver, name, arguments): {
	    		if(methodCall@decl in projectMethods1) {
					str calledVertex = getVertexName(methodCall@decl);
					callGraph += { <methodVertex, calledVertex> };
					methodCalls1[methodVertex] += { calledVertex };
				}
	    	}
		}		
	}
	unregisterProject(|project://junit-r4.9|);
	
	M3 projectModel2 = createM3(|project://junit-r4.10|);
	registerProject(|project://junit-r4.10|, projectModel2);
	
	set[loc] projectMethods2 = getM3Methods(projectModel2);
	
	println("Method count for JUnit 4.10: <size(projectMethods2)>");
	
	map[str, set[str]] methodCalls2 = ();
	map[str, loc] locations2 = ();
	
	for(method <- projectMethods2) {
		try node methodAST = getMethodASTEclipse(method, model = projectModel2);
		catch: continue;
		
		str methodVertex = getVertexName(method);
		
		locations2[methodVertex] = resolveM3(method);
		methodCalls2[methodVertex] = {};
		
		visit(methodAST) {
			case methodCall: \methodCall(isSuper, name, arguments): {
				if(methodCall@decl in projectMethods2) {
					str calledVertex = getVertexName(methodCall@decl);
					callGraph += { <methodVertex, calledVertex> };
					methodCalls2[methodVertex] += { calledVertex };
				}
			}
	    	case methodCall: \methodCall(isSuper, receiver, name, arguments): {
	    		if(methodCall@decl in projectMethods2) {
					str calledVertex = getVertexName(methodCall@decl);
					callGraph += { <methodVertex, calledVertex> };
					methodCalls2[methodVertex] += { calledVertex };
				}
	    	}
		}		
	}
	
	int seeds = 0;
	
	for(callSite <- methodCalls1) {
		if(callSite notin methodCalls2) {
			continue;
		}
		
		if(methodCalls1[callSite] != methodCalls2[callSite]) {
			println("<seeds>: <callSite>");
			println("Loc 1: <locations1[callSite]>");
			println("Loc 2: <locations2[callSite]>");
			seeds += 1;
		}
	}
	
	unregisterProject(|project://junit-r4.10|);
}